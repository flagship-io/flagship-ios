//
//  Flagship.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.

import Foundation

@objc public enum FStatus: NSInteger {
    // Flagship SDK has not been started or initialized successfully.
    case NOT_INITIALIZED = 0x0
    
    // Flagship SDK has been started successfully but is still polling campaigns.
    case POLLING = 0x10
    
    // Flagship SDK is ready but is running in Panic mode: All features are disabled except the one which refresh this status.
    case PANIC_ON = 0x20
    
    // Flagship SDK is ready to use.
    case READY = 0x100
    
    var name: String {
        switch self { case .NOT_INITIALIZED:
            return "NOT_INITIALIZED"
        case .POLLING:
            return "POLLING"
        case .PANIC_ON:
            return "PANIC_ON"
        case .READY:
            return "READY"
        }
    }
}

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
    var currentStatus: FStatus = .NOT_INITIALIZED
    
    // Enabale Log
    var enableLogs: Bool = true
    
    var lastInitializationTimestamp: TimeInterval

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
            Flagship.sharedInstance.updateStatus(.NOT_INITIALIZED)
            FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.ERROR_INIT_SDK)
            return
        }
        
        // Set the apiKey
        self.apiKey = apiKey
        
        // Set configuration
        currentConfig = config
        
        // If the mode bucketing we set the mode at NotReady, until the polling get the
        Flagship.sharedInstance.updateStatus((config.mode == .DECISION_API) ? .READY : .POLLING)

        FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.INIT_SDK(FlagShipVersion))
    }
    
    func newVisitor(_ visitorId: String, context: [String: Any] = [:], hasConsented: Bool = true, isAuthenticated: Bool) -> FSVisitor {
        let newVisitor = FSVisitor(aVisitorId: visitorId, aContext: context, aConfigManager: FSConfigManager(visitorId, config: currentConfig), aHasConsented: hasConsented, aIsAuthenticated: isAuthenticated)
        
        // Define strategy
        newVisitor.strategy = FSStrategy(newVisitor)
        
        if hasConsented {
            // Read the cached visitor
            newVisitor.strategy?.getStrategy().lookupVisitor()
            // Read the cacheed hits from data base
            newVisitor.strategy?.getStrategy().lookupHits() 

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
        currentStatus = .NOT_INITIALIZED
    }
    
    // Create new visitor
    @objc public func newVisitor(_ visitorId: String, instanceType: Instance = .SHARED_INSTANCE) -> FSVisitorBuilder {
        return FSVisitorBuilder(visitorId, instanceType: instanceType)
    }
    
    // Get status
    public func getStatus() -> FStatus {
        return currentStatus
    }
    
    // Update status
    func updateStatus(_ newStatus: FStatus) {
        // _ if the staus has not changed then no need to trigger the callback
        if newStatus == currentStatus {
            return
        }
        
        // Update the status
        currentStatus = newStatus
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
