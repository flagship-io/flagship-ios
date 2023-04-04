//
//  FSConfigManager.swift
//  Flagship
//
//  Created by Adel on 02/09/2021.
//

import Foundation

internal class FSConfigManager {
    /// visitorId
    let visitorId: String
    
    var flagshipConfig: FlagshipConfig
    
    var trackingManger: FSTrackingManager?
    
    var decisionManager: FSDecisionManager?
    
    private var service: FSService
    
    init(_ pVisitorId: String, config: FlagshipConfig) {
        /// Create service
        let shared = Flagship.sharedInstance
        self.service = FSService(shared.envId ?? "", shared.apiKey ?? "", pVisitorId, nil)
        
        /// Set the timeout
        service.timeOutServiceForRequestApi = config.timeout
        
        self.visitorId = pVisitorId
        
        self.flagshipConfig = config
        
        switch config.mode {
        case .DECISION_API:
            self.decisionManager = APIManager(service: service, userId: visitorId, currentContext: [:])
        default:
            self.decisionManager = FSBucketingManager(service: service, userId: visitorId, currentContext: [:], config.pollingTime)
            /// Prefere to launch the polling manually
            // decisionManager?.launchPolling()
        }
        /// Tracking manager
        switch config.trackingConfig.strategy {
        case .CONTINUOUS_CACHING_STRATEGY:
            self.trackingManger = ContinuousTrackingManager(service, config.trackingConfig, config.cacheManger)
        case .PERIODIC_CACHING_STRATEGY:
            self.trackingManger = PeriodicTrackingManager(service, config.trackingConfig, config.cacheManger)
        case .NO_BATCHING_CONTINUOUS_CACHING_STRATEGY:
            self.trackingManger = FSTrackingManager(service, config.trackingConfig)
        }
        // self.trackingManger = FSTrackingManager(service, config.trackingConfig)
        
        /// Check the connectivity
        FSTools().checkConnectevity()
    }
    
    /// Update the visitorId for service
    internal func updateVisitorId(_ visitorId: String) {
        service.visitorId = visitorId
    }

    /// Update the aid for service
    internal func updateAid(_ aid: String?) {
        service.anonymousId = aid
    }
}
