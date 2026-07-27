//
//  FSDefaultStrategy.swift
//  Flagship
//
//  Created by Adel on 10/09/2021.
//

import Foundation
#if os(iOS)
    import UIKit
#endif
class FSStrategy {
    let visitor: FSVisitor

    var delegate: FSDelegateStrategy?

    // MARK: - Smart strategy caching

    private var _cachedStrategy: FSDelegateStrategy?
    private var _lastSdkStatus: FSSdkStatus?
    private var _lastConsentStatus: Bool?
    private var _lastQAStatus: Bool?

    private var _qaStartObserver: NSObjectProtocol?
    private var _qaStopObserver: NSObjectProtocol?

    init(_ pVisitor: FSVisitor) {
        self.visitor = pVisitor
        _listenToQAAssistantStart()
        _listenToQAAssistantStop()
    }

    deinit {
        if let obs = _qaStartObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = _qaStopObserver  { NotificationCenter.default.removeObserver(obs) }
    }

    // MARK: - QA Notifications

    private func _listenToQAAssistantStart() {
        _qaStartObserver = NotificationCenter.default.addObserver(
            forName: .qaAssistantStarted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("✅ FSStrategy: QA Assistant started — switching to QAssistantStrategy"))
            Flagship.sharedInstance.isQAAssistantConnected = true

            // Pre-create QA strategy immediately so it's ready to receive broadcasts
            self._cachedStrategy = FSQAssistantStrategy(self.visitor)
            self._lastQAStatus = true

             // broadcast it to the QA Assistant so it knows which variations are live.
            var variations: [[String: String]] = []
            var processedVariations = Set<String>()

            for modification in self.visitor.currentFlags.values {
                let key = "\(modification.campaignId)_\(modification.variationId)"
                guard !processedVariations.contains(key) else { continue }
                processedVariations.insert(key)
                variations.append([
                    "campaignId":        modification.campaignId,
                    "variationId":       modification.variationId,
                    "variationGroupId":  modification.variationGroupId
                ])
            }

            FSQAMessageService.shared.broadcastFetchedFlagIds(variations)
            FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("📤 FSStrategy: Sent \(variations.count) fetched variation(s) to QA Assistant"))
        }
    }

    private func _listenToQAAssistantStop() {
        _qaStopObserver = NotificationCenter.default.addObserver(
            forName: .qaAssistantStoped,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("⏹️ FSStrategy: QA Assistant stopped — switching back to normal strategy"))
            Flagship.sharedInstance.isQAAssistantConnected = false
            // Invalidate cache so next call recreates the proper strategy
            self._cachedStrategy = nil
            self._lastQAStatus = false
        }
    }

    // MARK: - Smart getStrategy

    func getStrategy() -> FSDelegateStrategy {
        let currentStatus   = Flagship.sharedInstance.currentStatus
        let currentConsent  = visitor.hasConsented
        let currentQAStatus = Flagship.sharedInstance.isQAAssistantConnected

        // Re-create only when something relevant changed
        if _cachedStrategy == nil
            || _lastSdkStatus     != currentStatus
            || _lastConsentStatus != currentConsent
            || _lastQAStatus      != currentQAStatus
        {
            _cachedStrategy    = _createStrategy(status: currentStatus, consent: currentConsent, qaConnected: currentQAStatus)
            _lastSdkStatus     = currentStatus
            _lastConsentStatus = currentConsent
            _lastQAStatus      = currentQAStatus
        }

        return _cachedStrategy ?? FSNotReadyStrategy(visitor)
    }

    private func _createStrategy(status: FSSdkStatus, consent: Bool, qaConnected: Bool) -> FSDelegateStrategy {
        if qaConnected {
            FlagshipLogManager.Log(level: .ALL, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("🔄 FSStrategy: Using FSQAssistantStrategy"))
            return FSQAssistantStrategy(visitor)
        }
        switch status {
        case .SDK_INITIALIZED:
            return consent ? FSDefaultStrategy(visitor) : FSNoConsentStrategy(visitor)
        case .SDK_NOT_INITIALIZED:
            return FSNotReadyStrategy(visitor)
        case .SDK_PANIC:
            return FSPanicStrategy(visitor)
        default:
            return FSDefaultStrategy(visitor)
        }
    }
}

/////////// DEFAULT /////////////////////

class FSDefaultStrategy: FSDelegateStrategy {
    var visitor: FSVisitor
    init(_ pVisitor: FSVisitor) {
        self.visitor = pVisitor
    }
    
    func activateFlag(_ flag: FSFlag) {
        // Exit if we don’t have a modification present in current flag
        guard let modification = visitor.currentFlags[flag.key] else { return }

        // Get the informations
        let flagshipConfig = visitor.configManager.flagshipConfig
        let callback = flagshipConfig.onVisitorExposed
        let metadata = flag.metadata()
        let value = flag.value(defaultValue: flag.defaultValue, visitorExposed: false)

        // Prepare objetcs when callback exist
        var exposedFlag: FSExposedFlag?
        var exposedVisitor: FSVisitorExposed?
        if callback != nil {
            exposedFlag = FSExposedFlag(
                key: flag.key,
                defaultValue: flag.defaultValue,
                metadata: metadata,
                value: value
            )
            exposedVisitor = FSVisitorExposed(
                id: visitor.visitorId,
                anonymousId: visitor.anonymousId,
                context: visitor.context.currentContext
            )
        }

        // Build the activation hit
        let activateToSend = Activate(
            visitor.visitorId,
            visitor.anonymousId,
            modification: modification, exposedFlag?.toJson(),
            exposedVisitor?.toJson()
        )
        
        // Handle deduplication before sending hit
        let isDuplicate = visitor.isDeduplicatedFlag(
            campId: metadata.campaignId,
            varGrpId: metadata.variationGroupId
        )
        if isDuplicate {
            FlagshipLogManager.Log(level: .DEBUG, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Skip sending activation… variation already activated in this current session."))
            // if we have an exposedFlag, mark it and fire callback once
            if let ef = exposedFlag, let ev = exposedVisitor {
                ef.alreadyActivatedCampaign = true
                callback?(ev, ef)
            }
            return
        }

        // Send activation
        visitor.configManager.trackingManager?.sendActivate(
            activateToSend
        ) { error, exposedInfosArray in
            guard error == nil, let infos = exposedInfosArray else { return }
            infos.forEach { info in
                callback?(info.visitorExposed, info.exposedFlag)
            }
        }

        // Troubleshooting / TS hit
        FSDataUsageTracking.sharedInstance.processTSHits(
            label: CriticalPoints.VISITOR_SEND_ACTIVATE.rawValue,
            visitor: visitor,
            hit: activateToSend
        )
    }
 
    func synchronize(onSyncCompleted: @escaping (FSFlagStatus, FetchFlagsRequiredStatusReason) -> Void) {
        let startFetchingDate = Date() // To comunicate for TR
 
        FSDataUsageTracking.sharedInstance.processDataUsageTracking(v: visitor)
        visitor.configManager.decisionManager?.getCampaigns(visitor.context.getCurrentContext(), withConsent: visitor.hasConsented, visitor.assignedVariationHistory, completion: { campaigns, error in
            
            /// Create the dictionary for all flags
            if error == nil {
                if campaigns?.panic == true {
                    Flagship.sharedInstance.currentStatus = .SDK_PANIC
 
                    self.visitor.currentFlags.removeAll()
                    // Stop the process batching when the panic mode is ON
                    self.visitor.configManager.trackingManager?.stopBatchingProcess()
 
                    onSyncCompleted(.PANIC, .NONE)
 
                } else {
                    Flagship.sharedInstance.currentStatus = .SDK_INITIALIZED

                    /// Update new flags
                    self.visitor.updateFlagsAndAssignedHistory(campaigns?.getAllModification())
                
                    // Resume the process batching when the panic mode is OFF
                    self.visitor.configManager.trackingManager?.resumeBatchingProcess()
                    
                    onSyncCompleted(.FETCHED, .NONE)
                }
                // Update Data usage
                FSDataUsageTracking.sharedInstance.updateTroubleshooting(trblShooting: campaigns?.extras?.accountSettings?.troubleshooting)
                // Send TR
                FSDataUsageTracking.sharedInstance.processTSFetching(v: self.visitor, campaigns: campaigns, fetchingDate: startFetchingDate)
            } else {
                onSyncCompleted(.FETCH_REQUIRED, .FLAGS_FETCHING_ERROR) /// Even if we got an error, the sdk is ready to read flags, in this case the flag will be the default vlaue
            }
        })
    }
    
    func updateContext(_ newContext: [String: Any]) {
        // get the old one
        let oldContext = visitor.context.getCurrentContext()
        visitor.context.updateContext(newContext)

        if visitor.configManager.flagshipConfig.mode == .BUCKETING {
            if !visitor.context.isContextUnchanged(oldContext) {
                // The context changed .. need to uploar at the next fetch
                visitor.context.needToUpload = true
            }
        }
    }
    
    /// Get Flag Modification value
    func getFlagModification(_ key: String) -> FSModification? {
        return visitor.currentFlags[key]
    }
        
    func getModificationInfo(_ key: String) -> [String: Any]? {
        if let flagObject = visitor.currentFlags[key] {
            return ["campaignId": flagObject.campaignId,
                    "variationGroupId": flagObject.variationGroupId,
                    "variationId": flagObject.variationId,
                    "isReference": flagObject.isReference,
                    "campaignType": flagObject.type]
        }
        return nil
    }
    
    func getFlagStatus(_ key: String) -> FSFlagStatus {
        switch visitor.fetchStatus {
        case .FETCHED:
            if visitor.currentFlags.keys.contains(key) {
                return .FETCHED
            }
  
        case .FETCHING, .FETCH_REQUIRED:
            if visitor.currentFlags.keys.contains(key) {
                return .FETCH_REQUIRED
            }
        case .PANIC:
            return .PANIC
        default:
            return .NOT_FOUND
        }
        return .NOT_FOUND
    }
    
    func sendHit(_ hit: FSTrackingProtocol) {
        // Set the visitor Id and anonymous id  (See later to better )
        hit.visitorId = visitor.visitorId
        hit.anonymousId = visitor.anonymousId
        visitor.configManager.trackingManager?.sendHit(hit)
        // Troubleshooting hits
        FSDataUsageTracking.sharedInstance.processTSHits(label: CriticalPoints.VISITOR_SEND_HIT.rawValue, visitor: visitor, hit: hit)
    }
    
    /// _ Set Consent
    func setConsent(newValue: Bool) {
        /// Send new value on change consent
        visitor.sendHitConsent(newValue)
    }
    
    func authenticateVisitor(visitorId: String) {
        /// Update the visitor an anonymous id
        if visitor.anonymousId == nil {
            visitor.anonymousId = visitor.visitorId
        }
            
        // Set the authenticated visitorId
        visitor.visitorId = visitorId
            
        // Update fs_users for context
        visitor.context.currentContext.updateValue(visitorId, forKey: FS_USERS)
        #if os(iOS)
            // Update the xpc info for the emotion AI
            visitor.emotionCollect?.updateTupleId(visitorId: visitor.visitorId, anonymousId: visitor.anonymousId)
        #endif
    }
    
    func unAuthenticateVisitor() {
        if let anonymId = visitor.anonymousId {
            visitor.visitorId = anonymId
            // Update fs_users for context
            visitor.context.currentContext.updateValue(anonymId, forKey: FS_USERS)
        }
            
        visitor.anonymousId = nil
        #if os(iOS)
            // Update the xpc info for the emotion AI
            visitor.emotionCollect?.updateTupleId(visitorId: visitor.visitorId, anonymousId: visitor.anonymousId)
        #endif
    }
    
    /// _ Cache Managment
    
    func isVistorCacheExist() -> Bool {
        return visitor.configManager.flagshipConfig.cacheManager.isVisitorCacheExist(visitor.visitorId)
    }
    
    func cacheVisitor() {
        DispatchQueue.main.async {
            /// Before replacing the oldest visitor cache we should keep the oldest variation
            self.visitor.configManager.flagshipConfig.cacheManager.cacheVisitor(self.visitor)
        }
    }
    
    /// _ Lookup visitor
    func lookupVisitor() {
        var userId = visitor.visitorId
        if visitor.configManager.flagshipConfig.cacheManager.isVisitorCacheExist(visitor.visitorId) == false, let anId = visitor.anonymousId, anId != visitor.visitorId {
            userId = anId
        }
        lookupVisitorWithId(userId)
    }
    
    // MARK: - Private Helper Methods

    private func lookupVisitorWithId(_ visitorId: String) {
        visitor.configManager.flagshipConfig.cacheManager.lookupVisitorCache(visitoId: visitorId) { [weak self] error, cachedVisitor in
            guard let strongSelf = self else { return }
            if let cachedVisitor = cachedVisitor {
                strongSelf.processCachedVisitor(cachedVisitor)
            } else if let error = error {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to lookup visitor with id \(visitorId): \(error.localizedDescription)"))
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .ERROR_ON_READ_FILE)
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("No cached visitor found with id \(visitorId)"))
            }
        }
    }
    
    private func processCachedVisitor(_ cachedVisitor: FSCacheVisitor) {
        // Ensure thread safety for visitor property modifications
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.visitor.mergeCachedVisitor(cachedVisitor)
            // Safely merge assignation history
            let newHistory = cachedVisitor.data?.assignationHistory ?? [:]
            strongSelf.visitor.assignedVariationHistory.merge(newHistory) { _, new in new }
        }
    }
 
    /// _ Flush visitor
    func flushVisitor() {
        /// Flush the visitor
        visitor.configManager.flagshipConfig.cacheManager.flushVisitor(visitor.visitorId)
    }
    
    /// _ Lookup all hit relative to visitor
    func lookupHits() {
        visitor.configManager.trackingManager?.cacheManager?.lookupHits(onCompletion: { error, remainedHits in
            
            if error == nil {
                self.visitor.configManager.trackingManager?.addTrackingElementsToBatch(remainedHits ?? [])
                
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to lookup hit"))
            }
        })
    }
    
    /// _ Flush all hits relative to visitor
    func flushHits() {
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute: DispatchWorkItem {
            self.visitor.configManager.trackingManager?.flushTrackAndKeepConsent(self.visitor.visitorId)
        })
    }

    #if os(iOS)

        func collectEmotionsAIEvents(window: UIWindow?, screenName: String? = nil, usingSwizzling: Bool = false) {
            if visitor.emotionCollect != nil, visitor.emotionCollect?.status == .PROGRESS {
                FlagshipLogManager.Log(level: .ALL, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("The emotion collect is already running"))
                return
            }
            visitor.prepareEmotionAI { score, eaiVisitorScored in
                if !eaiVisitorScored {
                    // Init the emotion collect
                    self.visitor.emotionCollect = FSEmotionAI(visitorId: self.visitor.visitorId, usingSwizzling: usingSwizzling)
                    self.visitor.emotionCollect?.delegate = self.visitor
                    self.visitor.emotionCollect?.startEAICollectForView(window, nameScreen: screenName)
                } else {
                    self.visitor.eaiVisitorScored = true
                    self.visitor.emotionScoreAI = score
                    // cache the visitor infos
                    self.visitor.strategy?.getStrategy().cacheVisitor()
                    FlagshipLogManager.Log(level: .ALL, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("The user is already scored, no need to process EmotionAI collect again."))
                }
            }
        }
    
        func onAppScreenChange(_ screenName: String) {
            visitor.emotionCollect?.onAppScreenChange(screenName)
        }
    #endif
}

/// _ DELEGATE ///
protocol FSDelegateStrategy {
    /// update context
    func updateContext(_ newContext: [String: Any])
    
    /// Get Flag Modification
    func getFlagModification(_ key: String) -> FSModification?
    /// Synchronize
    func synchronize(onSyncCompleted: @escaping (FSFlagStatus, FetchFlagsRequiredStatusReason) -> Void)
    /// Activate flag
    func activateFlag(_ flag: FSFlag)
    /// Get Modification infos
    func getModificationInfo(_ key: String) -> [String: Any]?
    /// Send Hits
    func sendHit(_ hit: FSTrackingProtocol)
    /// Set Consent
    func setConsent(newValue: Bool)
    /// authenticateVisitor
    func authenticateVisitor(visitorId: String)
    /// unAuthenticateVisitor
    func unAuthenticateVisitor()
    
    /// _Cache Managment
    func cacheVisitor()
    
    /// _ Is Visitor cache Exist
    func isVistorCacheExist() -> Bool
    
    /// _ Lookup Visitor
    func lookupVisitor()
    
    /// _ Flush cache
    func flushVisitor()
    
    /// _ Lookup hits
    func lookupHits()
    
    /// _ Flush hits
    func flushHits()
    
    /// _ Get flag status
    func getFlagStatus(_ key: String) -> FSFlagStatus
    
    #if os(iOS)

        /// _ Start collection emotion AI
        func collectEmotionsAIEvents(window: UIWindow?, screenName: String?, usingSwizzling: Bool)
    
        /// _ onAppScreenChange
        func onAppScreenChange(_ screenName: String)
    #endif
}
