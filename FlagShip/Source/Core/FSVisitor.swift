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
    public var currentFlags: [String: FSModification] = [:] /// Empty
    /// Context
    internal var context: FSContext
    /// Configuration manager
    internal var configManager: FSConfigManager
    /// Strategy
    internal var strategy: FSStrategy?
    /// Has consented
    public internal(set) var hasConsented: Bool = true
    /// Is Authenticated
    public internal(set) var isAuthenticated: Bool = false
    
    /// Assigned hsitory
    internal var assignedVariationHistory: [String: String] = [:]

    init(aVisitorId: String, aContext: [String: Any], aConfigManager: FSConfigManager, aHasConsented: Bool, aIsAuthenticated: Bool) {
        /// Set authenticated
        self.isAuthenticated = aIsAuthenticated
        /// Before calling service manage the tuple (vid,aid)
        if self.isAuthenticated {
            self.visitorId = aVisitorId /// When the authenticated is true , the visitor id should not be nil
            self.anonymousId = FSTools.manageVisitorId(nil)
            /// When authenticated is true --> update the anonymousId given by the sdk
            aConfigManager.updateAid(self.anonymousId)
        } else {
            self.visitorId = FSTools.manageVisitorId(aVisitorId)
            self.anonymousId = nil
        }
                 
        Flagship.sharedInstance.currentStatus = (aConfigManager.flagshipConfig.mode == .DECISION_API) ? .READY : .NOT_INITIALIZED
        
        /// Set the user context
        self.context = FSContext(aContext)
        
        /// Set the presetcontext
        self.context.loadPreSetContext()

        /// Set config
        self.configManager = aConfigManager
        
        /// Set consent
        self.hasConsented = aHasConsented
        
        /// Set authenticated
        self.isAuthenticated = aIsAuthenticated
        
//        if aHasConsented {
//            /// Read the cached visitor
//            self.strategy?.getStrategy().lookupVisitor() /// See later for optimize
//            ///
//            self.strategy?.getStrategy().lookupHits() /// See later for optimize
//
//        } else {
//            /// user not consent then flush the cache related
//            self.strategy?.getStrategy().flushVisitor()
//        }
    }
    
    @objc public func fetchFlags(onFetchCompleted: @escaping () -> Void) {
        self.strategy?.getStrategy().synchronize(onSyncCompleted: { _ in
            onFetchCompleted()
            /// After the synchronize completion we cache the visitor
            self.strategy?.getStrategy().cacheVisitor()
            
            // If bucketing mode and no consent and no panic mode
            if Flagship.sharedInstance.currentStatus != .PANIC_ON, self.configManager.flagshipConfig.mode == .BUCKETING {
                self.sendHit(FSSegment(self.getContext()))
            }
           
        })
    }
    
    @available(*, deprecated, message: "Use fetchFlags")
    public func synchronize(onSyncCompleted: @escaping () -> Void) {
        self.strategy?.getStrategy().synchronize(onSyncCompleted: { _ in
            onSyncCompleted()
            /// After the synchronize completion we cache the visitor
            self.strategy?.getStrategy().cacheVisitor()
        })
    }
    
    /// Update Context
    /// - Parameter newContext: user's context
    @objc public func updateContext(_ context: [String: Any]) {
        self.strategy?.getStrategy().updateContext(context)
    }
    
    /// Update context with one
    /// - Parameters:
    ///   - key: key for the given value
    ///   - newValue: value for teh given key
    public func updateContext(_ key: String, _ newValue: Any) {
        self.strategy?.getStrategy().updateContext([key: newValue])
    }
    
    /// Update presetContext
    /// - Parameters:
    ///   - presetKey: name of the preset context, see PresetContext
    ///   - newValue: the value for the given key
    public func updateContext(_ flagshipContext: FlagshipContext, _ value: Any) {
        /// Check the validity value
        if !flagshipContext.chekcValidity(value) {
            FlagshipLogManager.Log(level: .ALL, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_PRE_CONTEXT_FAILED(flagshipContext.rawValue))
        }
        
        FlagshipLogManager.Log(level: .ALL, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_PRE_CONTEXT_SUCCESS(flagshipContext.rawValue))
        
        self.strategy?.getStrategy().updateContext([flagshipContext.rawValue: value])
    }
    
    /// Get the current context
    /// - Returns: Dictionary that represent a user context
    @objc public func getContext() -> [String: Any] {
        return self.context.getCurrentContext()
    }
    
    /// Clear the current context
    @objc public func clearContext() {
        self.context.clearContext()
    }
    
    /// Get Modification infos
    /// - Parameter key: key that represent the flag's name
    /// - Returns: the informations relative to this flag, if the key does not exist then return nil instead
    @available(*, deprecated, message: "Use getFlag(\"my_flag\").metadata")
    public func getModificationInfo(_ key: String) -> [String: Any]? {
        return self.strategy?.getStrategy().getModificationInfo(key)
    }
    
    /// Get the flag's value
    /// - Parameter key : key that represent the flag's name
    /// - parameter defaultValue : the value to return if the key does not exist
    /// - Parameter activate: if activate is true then send activate hit , no otherwise
    /// - Returns: The value for flag, if the key don't exist or the flag's type is different than default value then return default value
    @available(*, deprecated, message: "Use getFlag(\"my_flag\").value")
    public func getModification<T>(_ key: String, defaultValue: T, activate: Bool = false) -> T {
        if activate {
            self.activate(key)
        }
        
        return self.strategy?.getStrategy().getModification(key, defaultValue: defaultValue) ?? defaultValue
    }
    
    /// Activate tell to report that a visitor has seen a campaign
    /// - Parameter key: Modification identifier, represent flag's name
    @available(*, deprecated, message: "Use getFlag(\"my_flag\").userExposed()")
    public func activate(_ key: String) {
        if FSTools.isConnexionAvailable() {
            self.strategy?.getStrategy().activate(key) /// Refracto later
        } else {
            if let infoTosave = self.getActivateInformation(key) {
                // self.strategy?.getStrategy().saveHit(infoTosave, isActivateTracking: true)
            }
        }
    }
    
    /// Send Hits
    /// - Parameter T: Hit object
    public func sendHit<T: FSTrackingProtocol>(_ event: T) {
        //  if FSTools.isConnexionAvailable() {
        self.strategy?.getStrategy().sendHit(event)
          
//        } else {
//            /// Before save the body, save also the cst, will use it later on send
//            var bodyToSave = event.bodyTrack
//            bodyToSave.updateValue(event.getCst() ?? 0, forKey: "cst")
//            // self.strategy?.getStrategy().saveHit(bodyToSave, isActivateTracking: false)
//        }
    }
    
    /// Set consent
    
    /// Set the conssent
    /// - Parameter newValue: if true, then flush all stored visitor data
    @objc public func setConsent(hasConsented: Bool) {
        self.hasConsented = hasConsented
        self.strategy?.getStrategy().setConsent(newValue: hasConsented)
        
        /// the user don't consent then will flush the visitor
        if !hasConsented {
            self.strategy?.getStrategy().flushVisitor()
            self.strategy?.getStrategy().flushHits()
        }
    }
    
    /// Retrieve Flag by its key.
    /// - Parameter key:key associated to the flag
    /// - Parameter defaultValue:flag default value
    /// - Returns: FSFlag object, If no flag match the given key, an empty flag will be returned
    public func getFlag<T>(key: String, defaultValue: T?) -> FSFlag {
        /// Check the key if exist
        guard let modification = self.currentFlags[key] else {
            return FSFlag(key, nil, defaultValue, self.strategy)
        }

        return FSFlag(key, modification, defaultValue, self.strategy)
    }
    
    /////////////////
    ///            //
    /// internal   //
    ///            //
    /////////////////
    
    /// Check this part when test XPC
    internal func createTupleId() -> [String: String] {
        var tupleId = [String: String]()

        if self.anonymousId != nil /* && self.visitorId != nil */ {
            // envoyer: cuid = visitorId, et vid=anonymousId
            tupleId.updateValue(self.visitorId, forKey: "cuid") //// rename it
            tupleId.updateValue(self.anonymousId ?? "", forKey: "vid") //// rename it
        } else /* if self.visitorId != nil*/ {
            // Si visitorid défini mais pas anonymousId, cuid pas envoyé, vid = visitorId
            tupleId.updateValue(self.visitorId, forKey: "vid") //// rename it
        }
        return tupleId
    }
    
    /// Send Hit consent
    internal func sendHitConsent(_ hasConsented: Bool) {
        // create the hit consent
        let consentHit = FSConsent(eventCategory: .User_Engagement, eventAction: FSConsentAction)
        consentHit.visitorId = self.visitorId
        consentHit.anonymousId = self.anonymousId
        consentHit.label = String(format: "iOS:%@", hasConsented ? "true" : "false")
        self.strategy?.getStrategy().sendHit(consentHit)
    }
}
