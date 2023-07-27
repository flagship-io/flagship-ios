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
    
    var trackingManager: FSTrackingManager?
    
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
            // Prefere to launch the polling manually
            // decisionManager?.launchPolling()
        }
        // Tracking manager
        switch config.trackingConfig.strategy {
    
        case .CONTINUOUS_CACHING:
            self.trackingManager = ContinuousTrackingManager(service, config.trackingConfig, config.cacheManager)
        case .PERIODIC_CACHING:
            self.trackingManager = PeriodicTrackingManager(service, config.trackingConfig, config.cacheManager)
        case .NO_CACHING_STRATEGY:
            self.trackingManager = FSTrackingManager(service, config.trackingConfig, config.cacheManager)
        }        
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
