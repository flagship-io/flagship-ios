//
//  FSVisitor.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.
//

import Foundation

/**
 * Specify if how Flagship SDK should handle the newly create visitor instance.
 */
@objc public enum Instance: Int {
    /**
     * The  newly created visitor instance will be returned and saved into the Flagship singleton. Call `Flagship.getVisitor()` to retrieve the instance.
     * This option should be adopted on applications that handle only one visitor at the same time.
     */
    case SHARED_INSTANCE

    /**
     * The newly created visitor instance wont be saved and will simply be returned. Any previous visitor instance will have to be recreated.
     * This option should be adopted on applications that handle multiple visitors at the same time.
     */
    case NEW_INSTANCE
}

/// Visitor class
@objc public class FSVisitor: NSObject {
    let fsQueue = DispatchQueue(label: "com.flagshipVisitor.queue", attributes: .concurrent)
    /// visitor id
    public internal(set) var visitorId: String {
        willSet(newValue) {
            self.configManager.updateVisitorId(newValue)
        }
    }

    public internal(set) var anonymousId: String? {
        willSet(newValue) {
            self.configManager.updateAid(newValue)
        }
    }

    /// Modifications
    var currentFlags: [String: FSModification] = [:]
    /// Context
    var context: FSContext
    /// Strategy
    var strategy: FSStrategy?
    /// Has consented
    public internal(set) var hasConsented: Bool = true
    /// Is Authenticated
    public internal(set) var isAuthenticated: Bool = false
    
    /// Assigned hsitory
    var assignedVariationHistory: [String: String] = [:]
    
    // The fetch reason
    public internal(set) var requiredFetchReason: FetchFlagsRequiredStatusReason = .FLAGS_NEVER_FETCHED
    
    /// Configuration manager
    var configManager: FSConfigManager
    
    // Scored visitor
    public internal(set) var eaiVisitorScored: Bool = false
        
    // Score value
    public internal(set) var emotionScoreAI: String? = nil

    // Refonte status
    public internal(set) var fetchStatus: FSFlagStatus = .FETCH_REQUIRED {
        didSet {
            // Trigger the changed callback
            self._onFlagStatusChanged?(self.fetchStatus)
            // Trigger the required callback
            if self.fetchStatus == .FETCH_REQUIRED {
                self._onFlagStatusFetchRequired?(self.requiredFetchReason)
            }
            // Trigger the fetched callback
            if self.fetchStatus == .FETCHED {
                self._onFlagStatusFetched?()
            }
        }
    }
    
    // Called every time the Flag status changes.
    var _onFlagStatusChanged: OnFlagStatusChanged = nil
    // Called every time when the FlagStatus is equals to FETCH_REQUIRED
    var _onFlagStatusFetchRequired: OnFlagStatusFetchRequired = nil
    // Called every time when the FlagStatus is equals to FETCHED.
    var _onFlagStatusFetched: OnFlagStatusFetched = nil
    
    #if os(iOS)
        var emotionCollect: FSEmotionAI?
    #endif
    
    init(aVisitorId: String, aContext: [String: Any], aConfigManager: FSConfigManager, aHasConsented: Bool, aIsAuthenticated: Bool, pOnFlagStatusChanged: OnFlagStatusChanged,
         pOnFlagStatusFetchRequired: OnFlagStatusFetchRequired,
         pOnFlagStatusFetched: OnFlagStatusFetched)
    {
        // Set Authenticated
        self.isAuthenticated = aIsAuthenticated
        // Before calling service manage the tuple (vid,aid)
        if self.isAuthenticated {
            self.visitorId = aVisitorId /// When the authenticated is true , the visitor id should not be nil
            self.anonymousId = FSTools.manageVisitorId(nil)
            // When authenticated is true --> update the anonymousId given by the sdk
            aConfigManager.updateAid(self.anonymousId)
        } else {
            self.visitorId = FSTools.manageVisitorId(aVisitorId)
            self.anonymousId = nil
        }
        
        // Set the user context
        self.context = FSContext(aContext, visitorId: aVisitorId)
        
        // Set the presetContext
        self.context.loadPreSetContext()
        
        // Set config
        self.configManager = aConfigManager
        
        // Set consent
        self.hasConsented = aHasConsented
        
        // Set authenticated
        self.isAuthenticated = aIsAuthenticated
        
        // Set Callback(s)
        self._onFlagStatusChanged = pOnFlagStatusChanged
        self._onFlagStatusFetchRequired = pOnFlagStatusFetchRequired
        self._onFlagStatusFetched = pOnFlagStatusFetched
    }
    
    @objc public func fetchFlags(onFetchCompleted: @escaping () -> Void) {
        self.prepareEmotionAI(onCompleted: { score, _ in
            // Set the score
            self.emotionScoreAI = score
            
            // Update the context only if the score is not nil
            if let aScore = score {
                self.context.updateContext("eai::eas", aScore)
            }
            
            // Go to ING state while the fetch is ongoing
            self.fetchStatus = .FETCHING
            
            /// Look for the visitor in local storage
            self.strategy?.getStrategy().lookupVisitor()
            
            // Synchronize the visitor
            self.strategy?.getStrategy().synchronize(onSyncCompleted: { state, reason in
     
                // After the synchronize completion we cache the visitor
                self.strategy?.getStrategy().cacheVisitor()
                
                // If bucketing mode & no consent & no panic mode
                if self.configManager.flagshipConfig.mode == .BUCKETING, Flagship.sharedInstance.currentStatus != .SDK_PANIC {
                    if self.context.needToUpload && self.hasConsented { // If the context is changed and consent then => send segment hit
                        self.sendHit(FSSegment(self.getContext()))
                        self.context.needToUpload = false
                    }
                    
                    // Another task for bucketing in xpc mode is to save the anonymous when has no cache
                    
                    if let ano = self.anonymousId {
                        if !self.configManager.flagshipConfig.cacheManager.isVisitorCacheExist(ano) {
                            let anoVisitor: FSVisitor = self.copy()
                            anoVisitor.visitorId = ano
                            self.configManager.flagshipConfig.cacheManager.cacheVisitor(anoVisitor)
                        }
                    }
                }
                // Update the reason status
                self.requiredFetchReason = reason
                // Update the fetch status
                self.fetchStatus = state
                onFetchCompleted()
            })
        })
    }

    func prepareEmotionAI(onCompleted: @escaping (_ score: String?, _ isAlreadyScored: Bool) -> Void) {
        // EAIActivation is enabled
        if Flagship.sharedInstance.eaiActivationEnabled {
            if self.eaiVisitorScored { // If the user is already scored go look for the score in local first
                // The visitor score should be updated with the value stored in cache
                if let aScore = self.emotionScoreAI {
                    FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("This user has an existing score: \"\(aScore)\" in local cache"))
                    // Complete block with score
                    FSDataUsageTracking.sharedInstance.processTSEmotionsCachedScore(visitorId: self.visitorId, anonymousId: self.anonymousId, score: aScore)
                    onCompleted(aScore, true)
                }
            } else { // Not scored, but w'll check in remote if we have already a score for this user
                FSSettings().fetchScore(visitorId: self.visitorId, completion: { score, _ in
                    if let aScore = score {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("This user has an existing score: \"\(aScore)\" in eai server "))
                        onCompleted(aScore, true)
                    } else {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("The user \"\(self.visitorId)\" is never scored."))
                        onCompleted(nil, false)
                    }
                })
            }
        } else {
            // The eaiActivationEnabled not enabled -- Go for the collection anyway
            onCompleted(nil, false)
        }
    }
    
    //////////////////////
    //        CONTEXT   //
    //////////////////////
    
    // Update Context
    // - Parameter newContext: user's context
    @objc public func updateContext(_ context: [String: Any]) {
        self._updateContext(context)
    }
    
    // Update context with one
    // - Parameters:
    //   - key: key for the given value
    //   - newValue: value for teh given key
    public func updateContext(_ key: String, _ newValue: Any) {
        self._updateContext([key: newValue])
    }
    
    // Update presetContext
    // - Parameters:
    //   - presetKey: name of the preset context, see PresetContext
    //   - newValue: the value for the given key
    public func updateContext(_ flagshipContext: FlagshipContext, _ value: Any) {
        /// Check the validity value
        if !flagshipContext.chekcValidity(value) {
            FlagshipLogManager.Log(level: .ALL, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_PRE_CONTEXT_FAILED(flagshipContext.rawValue))
        }
        
        FlagshipLogManager.Log(level: .ALL, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_PRE_CONTEXT_SUCCESS(flagshipContext.rawValue))
        
        self._updateContext([flagshipContext.rawValue: value])
    }
    
    private func _updateContext(_ newContext: [String: Any]) {
        self.strategy?.getStrategy().updateContext(newContext)
        self.requiredFetchReason = .VISITOR_CONTEXT_UPDATED
        self.fetchStatus = .FETCH_REQUIRED
    }
    
    // Get the current context
    // - Returns: Dictionary that represent a user context
    @objc public func getContext() -> [String: Any] {
        return self.context.getCurrentContext()
    }
    
    // Clear the current context
    @objc public func clearContext() {
        self.context.clearContext()
    }
    
    // Send Hits
    // - Parameter T: Hit object
    public func sendHit<T: FSTrackingProtocol>(_ event: T) {
        self.strategy?.getStrategy().sendHit(event)
    }
    
    //  Set consent
    
    // Set the conssent
    // - Parameter newValue: if true, then flush all stored visitor data
    @objc public func setConsent(hasConsented: Bool) {
        self.hasConsented = hasConsented
        self.strategy?.getStrategy().setConsent(newValue: hasConsented)
        
        // the user don't consent then will flush the visitor
        if !hasConsented {
            self.strategy?.getStrategy().flushVisitor()
            self.strategy?.getStrategy().flushHits()
        }
        
        // Update the value for the data usage tracking
        FSDataUsageTracking.sharedInstance.updateConsent(newValue: hasConsented)
    }
    
    // ///////////////
    // /            //
    // / internal   //
    // /            //
    // ///////////////
    
    // Send Hit consent
    func sendHitConsent(_ hasConsented: Bool) {
        // create the hit consent
        let consentHit = FSConsent(eventCategory: .User_Engagement, eventAction: FSConsentAction)
        consentHit.visitorId = self.visitorId
        consentHit.anonymousId = self.anonymousId
        consentHit.label = String(format: "iOS:%@", hasConsented ? "true" : "false")
        self.strategy?.getStrategy().sendHit(consentHit)
    }
}
