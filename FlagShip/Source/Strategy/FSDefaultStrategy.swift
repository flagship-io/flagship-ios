//
//  FSDefaultStrategy.swift
//  Flagship
//
//  Created by Adel on 10/09/2021.
//

import Foundation

class FSStrategy {
    let visitor: FSVisitor
    
    var status: FStatus
    
    internal var delegate: FSDelegateStrategy?
    
    internal func getStrategy() -> FSDelegateStrategy {
        switch Flagship.sharedInstance.currentStatus {
        case .READY:
            if visitor.hasConsented == true {
                return FSDefaultStrategy(visitor)
            } else {
                return FSNoConsentStrategy(visitor)
            }
        case .NOT_INITIALIZED:
            return FSNotReadyStrategy(visitor)
        case .PANIC_ON:
            return FSPanicStrategy(visitor)
        default:
            return FSDefaultStrategy(visitor)
        }
    }
    
    init(_ pVisitor: FSVisitor, state: FStatus) {
        self.visitor = pVisitor
        
        self.status = state
    }
}

/////////// DEFAULT /////////////////////

class FSDefaultStrategy: FSDelegateStrategy {
    var visitor: FSVisitor
    
    var assignedHistory: [String: String] = [:]

    init(_ pVisitor: FSVisitor) {
        self.visitor = pVisitor
    }
    
    /// Activate
    func activate(_ key: String) {
        /// Add envId to dictionary
        // let shared = Flagship.sharedInstance
            
        if let aModification = visitor.currentFlags[key] {
//            var infosTrack = ["vaid": aModification.variationId, "caid": aModification.variationGroupId, "vid": visitor.visitorId]
//
//            if let aId = visitor.anonymousId {
//                infosTrack.updateValue(aId, forKey: "aid")
//            }
//            if let aEnvId = shared.envId {
//                infosTrack.updateValue(aEnvId, forKey: "cid")
//            }
            visitor.configManager.trackingManger?.sendActivate(Activate(visitor.visitorId, visitor.anonymousId, modification: aModification))
        }
    }
    
    func synchronize(onSyncCompleted: @escaping (FStatus) -> Void) {
        visitor.configManager.decisionManager?.getCampaigns(visitor.context.getCurrentContext(), withConsent: visitor.hasConsented, completion: { campaigns, error in
            
            /// Create the dictionary for all flags
            if error == nil {
                if campaigns?.panic == true {
                    Flagship.sharedInstance.currentStatus = .PANIC_ON
                    self.visitor.currentFlags.removeAll()
                    // Stop the process batching when the panic mode is ON
                    self.visitor.configManager.trackingManger?.stopBatchingProcess()
                    onSyncCompleted(.PANIC_ON)
                    
                } else {
                    /// Update new flags
                    self.visitor.updateFlags(campaigns?.getAllModification())
                    Flagship.sharedInstance.currentStatus = .READY
                    // Resume the process batching when the panic mode is OFF
                    self.visitor.configManager.trackingManger?.resumeBatchingProcess()

                    onSyncCompleted(.READY)
                }
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: .MESSAGE(error.debugDescription))
                onSyncCompleted(.READY) /// Even if we got an error, the sdk is ready to read flags, in this case the flag will be the default vlaue
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
    
    func sendHit(_ hit: FSTrackingProtocol) {
        // Set the visitor Id and anonymous id  (See later to better )
        hit.visitorId = visitor.visitorId
        hit.anonymousId = visitor.anonymousId
        visitor.configManager.trackingManger?.sendHit(hit)
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
            self.visitor.configManager.flagshipConfig.cacheManger.cacheVisitor(self.visitor)
        }
    }
    
    /// _ Lookup visitor
    func lookupVisitor() {
        /// Read the visitor cache from storage
        visitor.configManager.flagshipConfig.cacheManger.lookupVisitorCache(visitoId: visitor.visitorId) { error, cachedVisitor in
            
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
        visitor.configManager.flagshipConfig.cacheManger.flushVisitor(visitor.visitorId)
    }
    
    /// _ Lookup all hit relative to visitor
    func lookupHits() {
        visitor.configManager.trackingManger?.cacheManager?.lookupHits(onCompletion: { error, remainedHits in
            
            if error == nil {
                self.visitor.configManager.trackingManger?.addTrackingElementsToBatch(remainedHits ?? [])
                
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to lookup hit"))
            }
        })
    }
    
    /// _ Flush all hits relative to visitor
    func flushHits() {
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute: DispatchWorkItem {
            self.visitor.configManager.trackingManger?.flushTrackAndKeepConsent(self.visitor.visitorId)
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
    func synchronize(onSyncCompleted: @escaping (FStatus) -> Void)
    /// Activate
    func activate(_ key: String)
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
}
