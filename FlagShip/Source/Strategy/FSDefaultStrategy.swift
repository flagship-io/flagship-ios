//
//  FSDefaultStrategy.swift
//  Flagship
//
//  Created by Adel on 10/09/2021.
//

import Foundation

class FSStrategy {
    let visitor: FSVisitor
    
    var delegate: FSDelegateStrategy?
    
//    func getStrategy() -> FSDelegateStrategy {
//        switch Flagship.sharedInstance.currentStatus {
//        case .READY:
//            if visitor.hasConsented == true {
//                return FSDefaultStrategy(visitor)
//            } else {
//                return FSNoConsentStrategy(visitor)
//            }
//        case .NOT_INITIALIZED:
//            return FSNotReadyStrategy(visitor)
//        case .PANIC_ON:
//            return FSPanicStrategy(visitor)
//        default:
//            return FSDefaultStrategy(visitor)
//        }
//    }
    
    func getStrategy() -> FSDelegateStrategy {
        switch Flagship.sharedInstance.currentStatus {
        case .SDK_INITIALIZED:
            if visitor.hasConsented == true {
                return FSDefaultStrategy(visitor)
            } else {
                return FSNoConsentStrategy(visitor)
            }
        case .SDK_NOT_INITIALIZED:
            return FSNotReadyStrategy(visitor)
        case .SDK_PANIC:
            return FSPanicStrategy(visitor)
        default:
            return FSDefaultStrategy(visitor)
        }
    }

    init(_ pVisitor: FSVisitor) {
        self.visitor = pVisitor
    }
}

/////////// DEFAULT /////////////////////

class FSDefaultStrategy: FSDelegateStrategy {
    var visitor: FSVisitor
    init(_ pVisitor: FSVisitor) {
        self.visitor = pVisitor
    }
    
    /// Activate
    func activate(_ key: String) {
        if let aModification = visitor.currentFlags[key] {
            let activateToSend = Activate(visitor.visitorId, visitor.anonymousId, modification: aModification)
            visitor.configManager.trackingManager?.sendActivate(activateToSend, onCompletion: { error, _ in
                
                if error == nil {}
            })
            
            // Troubleshooitng activate
            FSDataUsageTracking.sharedInstance.processTSHits(label: CriticalPoints.VISITOR_SEND_ACTIVATE.rawValue, visitor: visitor, hit: activateToSend)
        }
    }
    
    /// Activate Flag
    func activateFlag(_ flag: FSFlag) {
        if let aModification = visitor.currentFlags[flag.key] {
            // Define Exposed flag and exposed visitor
            var exposedFlag, exposedVisitor: String?
            if visitor.configManager.flagshipConfig.onVisitorExposed != nil {
                // Create flag exposed object
                exposedFlag = FSExposedFlag(key: flag.key, defaultValue: flag.defaultValue, metadata: flag.metadata(), value: flag.value(defaultValue: flag.defaultValue, visitorExposed: false)).toJson()
                // Create visitor expose object
                exposedVisitor = FSVisitorExposed(id: visitor.visitorId, anonymousId: visitor.anonymousId, context: visitor.getContext()).toJson()
            }
            
            let activateToSend = Activate(visitor.visitorId, visitor.anonymousId, modification: aModification, exposedFlag, exposedVisitor)
            visitor.configManager.trackingManager?.sendActivate(activateToSend, onCompletion: { error, exposedInfosArray in
                
                if error == nil {
                    /// Is callback is defined ===> Trigger it
                    if let aOnVisitorExposed = self.visitor.configManager.flagshipConfig.onVisitorExposed {
                        exposedInfosArray?.forEach { item in
                            aOnVisitorExposed(item.visitorExposed, item.exposedFlag)
                        }
                    }
                } else {
                    // The flag error
                }
            })
            // Troubleshooitng activate
            FSDataUsageTracking.sharedInstance.processTSHits(label: CriticalPoints.VISITOR_SEND_ACTIVATE.rawValue, visitor: visitor, hit: activateToSend)
        }
    }
    
    func synchronize(onSyncCompleted: @escaping (FSFetchStatus, FSFetchReasons) -> Void) {
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
                    /// Update new flags
 
                    self.visitor.updateFlagsAndAssignedHistory(campaigns?.getAllModification())
 
                    Flagship.sharedInstance.currentStatus = .SDK_INITIALIZED
 
                    self.visitor.updateFlagsAndAssignedHistory(campaigns?.getAllModification())
                
                    // Resume the process batching when the panic mode is OFF
                    self.visitor.configManager.trackingManager?.resumeBatchingProcess()
                    // Update the flagSyncStatus
                    self.visitor.flagSyncStatus = .FLAGS_FETCHED
 
                    onSyncCompleted(.FETCHED, .NONE)
                }
                // Update Data usage
                FSDataUsageTracking.sharedInstance.updateTroubleshooting(trblShooting: campaigns?.extras?.accountSettings?.troubleshooting)
                // Send TR
                FSDataUsageTracking.sharedInstance.processTSFetching(v: self.visitor, campaigns: campaigns, fetchingDate: startFetchingDate)
            } else {
                onSyncCompleted(.FETCH_REQUIRED, .FETCH_ERROR) /// Even if we got an error, the sdk is ready to read flags, in this case the flag will be the default vlaue
            }
        })
    }
    
    func updateContext(_ newContext: [String: Any]) {
        visitor.context.updateContext(newContext)
    }
    
    func getModification<T>(_ key: String, defaultValue: T) -> T {
        if let flagObject = visitor.currentFlags[key] {
            if flagObject.value is T {
                return flagObject.value as? T ?? defaultValue
            }
        }
        return defaultValue
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
        if visitor.configManager.flagshipConfig.mode == .DECISION_API {
            /// Update the visitor an anonymous id
            if visitor.anonymousId == nil {
                visitor.anonymousId = visitor.visitorId
            }
            
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .AUTHENTICATE, messageToDisplay: FSLogMessage.IGNORE_AUTHENTICATE)
        }
        
        visitor.visitorId = visitorId
    }
    
    func unAuthenticateVisitor() {
        if visitor.configManager.flagshipConfig.mode == .DECISION_API {
            if let anonymId = visitor.anonymousId {
                visitor.visitorId = anonymId
            }
            
            visitor.anonymousId = nil
            
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .AUTHENTICATE, messageToDisplay: FSLogMessage.IGNORE_UNAUTHENTICATE)
        }
    }
    
    /// _ Cache Managment
    func cacheVisitor() {
        DispatchQueue.main.async {
            /// Before replacing the oldest visitor cache we should keep the oldest variation
            self.visitor.configManager.flagshipConfig.cacheManager.cacheVisitor(self.visitor)
        }
    }
    
    /// _ Lookup visitor
    func lookupVisitor() {
        /// Read the visitor cache from storage
        visitor.configManager.flagshipConfig.cacheManager.lookupVisitorCache(visitoId: visitor.visitorId) { error, cachedVisitor in
            
            if error == nil {
                if let aCachedVisitor = cachedVisitor {
                    self.visitor.mergeCachedVisitor(aCachedVisitor)
                    /// Get the oldest assignation history before saving and loose the information
                    self.visitor.assignedVariationHistory.merge(aCachedVisitor.data?.assignationHistory ?? [:]) { _, new in new }
                }
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .ERROR_ON_READ_FILE)
            }
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
}

/// _ DELEGATE ///
protocol FSDelegateStrategy {
    /// update context
    func updateContext(_ newContext: [String: Any])
    //// Get generique
    func getModification<T>(_ key: String, defaultValue: T) -> T
    /// Get Flag Modification
    func getFlagModification(_ key: String) -> FSModification?
    /// Synchronize
    // func synchronize(onSyncCompleted: @escaping (FStatus) -> Void)
    
    /// Synchronize Bis
 
    // func synchronize(onSyncCompleted: @escaping (FSSdkStatus) -> Void)
    
    func synchronize(onSyncCompleted: @escaping (FSFetchStatus, FSFetchReasons) -> Void)
 
    /// Activate
    func activate(_ key: String)
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
}
