//
//  Flagship.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.

import Foundation

public class Flagship: NSObject {
    // envId
    var envId: String?
    // apiKey
    var apiKey: String?
    // Configuration
    var currentConfig: FlagshipConfig = FSConfigBuilder().build()
    // Current visitor
    @objc public private(set) var sharedVisitor: FSVisitor?
    // Current status
    // var currentStatus: FStatus = .NOT_INITIALIZED
    
    // New refonte status
    var currentStatus: FSSdkStatus = .SDK_NOT_INITIALIZED
    
    // New refonte status
    var currentStatusBis: FSSdkStatus = .SDK_NOT_INITIALIZED
    
    // Enabale Log
    var enableLogs: Bool = true
    
    var lastInitializationTimestamp: TimeInterval
    
    /// In context of refonte
    var pollingScript: FSPollingScript?
 
   
    // Shared instace
    @objc public static let sharedInstance: Flagship = {
        let instance = Flagship()
        // setup code
        return instance
    }()
    
    override private init() {
        lastInitializationTimestamp = Date().timeIntervalSince1970
    }
    
    @objc public func start(envId: String, apiKey: String, config: FlagshipConfig = FSConfigBuilder().build()) {
        // Check the environmentId
        if FSTools.chekcXidEnvironment(envId) {
            self.envId = envId
            
        } else {
            // Flagship.sharedInstance.updateStatus(.NOT_INITIALIZED)
            // Refonte update
            Flagship.sharedInstance.updateStatus(.SDK_NOT_INITIALIZED)
 

            FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.ERROR_INIT_SDK)
            return
        }
        
        // Set the apiKey
        self.apiKey = apiKey
        
        // Set configuration
        currentConfig = config
        
        // If the mode bucketing we set the mode at NotReady, until the polling get the
        // Flagship.sharedInstance.updateStatus((config.mode == .DECISION_API) ? .READY : .POLLING)
        
        // Refonte
         Flagship.sharedInstance.updateStatus((config.mode == .DECISION_API) ? .SDK_INITIALIZED : .SDK_INITIALIZING)
 

        FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.INIT_SDK(FlagShipVersion))
        
        ///  Bucketing service
        if config.mode == .BUCKETING {
            pollingScript = FSPollingScript(pollingTime: config.pollingTime)
 
            // pollingScript?.launchPolling()
        }
    }
    
    func newVisitor(_ visitorId: String, context: [String: Any] = [:], hasConsented: Bool = true, isAuthenticated: Bool, pOnFetchFlagStatusChanged: OnFetchFlagsStatusChanged) -> FSVisitor {
        let newVisitor = FSVisitor(aVisitorId: visitorId, aContext: context, aConfigManager: FSConfigManager(visitorId, config: currentConfig), aHasConsented: hasConsented, aIsAuthenticated: isAuthenticated, pOnFlagStatusChanged: pOnFetchFlagStatusChanged)
        
        // Define strategy
        newVisitor.strategy = FSStrategy(newVisitor)
        
        if hasConsented {
            // Read the cached visitor
            newVisitor.strategy?.getStrategy().lookupVisitor() /// See later for optimize
            //
            newVisitor.strategy?.getStrategy().lookupHits() /// See later for optimize

        } else {
            // user not consent then flush the cache related
            newVisitor.strategy?.getStrategy().flushVisitor()
        }
        
        // Send consent hit
        newVisitor.sendHitConsent(hasConsented)
        
        // Config data usage tracking
        FSDataUsageTracking.sharedInstance.configureWithVisitor(pVisitor: newVisitor)
        
        return newVisitor
    }
    
    // Set the shared visitor
    public func setSharedVisitor(_ visitor: FSVisitor) {
        Flagship.sharedInstance.sharedVisitor = visitor
    }
    
    // Reset the sdk
    func reset() {
        sharedVisitor = nil
        //  currentStatus = .NOT_INITIALIZED
    }
    
    // Create new visitor
    @objc public func newVisitor(_ visitorId: String, instanceType: Instance = .SHARED_INSTANCE) -> FSVisitorBuilder {
        return FSVisitorBuilder(visitorId, instanceType: instanceType)
    }
    
    // Get status
    public func getStatus() -> FSSdkStatus {
        return currentStatus
 
    }
    
//    // Update status
//    func updateStatus(_ newStatus: FStatus) {
//        // _ if the staus has not changed then no need to trigger the callback
//        if newStatus == currentStatus {
//            return
//        }
//
//        // Update the status
//        currentStatus = newStatus
//        // Trigger the callback
//        if let callbackListener = currentConfig.onStatusChanged {
//          //  callbackListener(newStatus)
//        }
//    }
    
    // Update status
 
    func updateStatus(_ newStatus: FSSdkStatus) {
 
        // _ if the staus has not changed then no need to trigger the callback
        if newStatus == currentStatusBis {
            return
        }
        print("--------------------------------- \(newStatus.name) ----------------------------------")
        
        // Update the status
        currentStatusBis = newStatus
        // Trigger the callback
        if let callbackListener = currentConfig.onStatusChanged {
            callbackListener(newStatus)
        }
    }
    
    // When close is called will trigger all hits present in batch
    @objc public func close() {
        Flagship.sharedInstance.sharedVisitor?.configManager.trackingManager?.batchManager.batchFromQueue()
    }
}
