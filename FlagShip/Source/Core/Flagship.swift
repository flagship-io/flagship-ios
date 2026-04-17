//
//  Flagship.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.

import Foundation

public class Flagship: NSObject {
    let fsQueue = DispatchQueue(label: "flagship.queue", attributes: .concurrent)
    
    // envId
    var envId: String?
    // apiKey
    var apiKey: String?
    // Configuration
    var currentConfig: FlagshipConfig = FSConfigBuilder().build()
    // Current visitor
    @objc public private(set) var sharedVisitor: FSVisitor?
    // Enabale Log
    var enableLogs: Bool = true
    // Polling script
    var pollingScript: FSPollingScript?
    // Last init timestamps
    var lastInitializationTimestamp: String
    
    // Emotion AI collect is enabled
    var eaiCollectEnabled: Bool = false
    
    var eaiActivationEnabled: Bool = false
    
    var currentStatus: FSSdkStatus {
        get {
            return fsQueue.sync {
                _currentStatus
            }
        }
        set {
            fsQueue.async(flags: .barrier) {
                self._currentStatus = newValue
            }
        }
    }
    
    private var _currentStatus: FSSdkStatus = .SDK_NOT_INITIALIZED
    
    // Shared instace
    @objc public static let sharedInstance: Flagship = {
        let instance = Flagship()
        // setup code
        return instance
    }()

    override private init() {
        lastInitializationTimestamp = FSTools.getUtcTimestamp()
    }
    
    @objc public func start(envId: String, apiKey: String, config: FlagshipConfig = FSConfigBuilder().build()) {
        // Check the environmentId
        if FSTools.chekcXidEnvironment(envId) {
            Flagship.sharedInstance.envId = envId
            
        } else {
            Flagship.sharedInstance.updateStatus(.SDK_NOT_INITIALIZED)
 
            FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.ERROR_INIT_SDK)
            return
        }
        
        // Set the apiKey
        self.apiKey = apiKey
        
        // Set configuration
        Flagship.sharedInstance.currentConfig = config
        
        switch config.mode { case .DECISION_API:
            Flagship.sharedInstance.updateStatus(.SDK_INITIALIZED)
        case .BUCKETING:
            // Init the polling script
            pollingScript = FSPollingScript(pollingTime: config.pollingTime)
            // Update status depend on the buckeitng file
            Flagship.sharedInstance.updateStatus(FSStorageManager.bucketingScriptAlreadyAvailable() ? .SDK_INITIALIZED : .SDK_INITIALIZING)
        }
        
        FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.INIT_SDK(FlagShipVersion))
    }
    

    
    func newVisitor(_ visitorId: String, context: [String: Any] = [:], hasConsented: Bool = true, isAuthenticated: Bool, pOnFlagStatusChanged: OnFlagStatusChanged, pOnFlagStatusFetchRequired: OnFlagStatusFetchRequired, pOnFlagStatusFetched: OnFlagStatusFetched) -> FSVisitor {
        let newVisitor = FSVisitor(aVisitorId: visitorId, aContext: context, aConfigManager: FSConfigManager(visitorId, config: currentConfig), aHasConsented: hasConsented,
                                   aIsAuthenticated: isAuthenticated,
                                   pOnFlagStatusChanged: pOnFlagStatusChanged,
                                   pOnFlagStatusFetchRequired: pOnFlagStatusFetchRequired,
                                   pOnFlagStatusFetched: pOnFlagStatusFetched)
        
        // Define strategy
        newVisitor.strategy = FSStrategy(newVisitor)
        
        if hasConsented {
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
        currentStatus = .SDK_NOT_INITIALIZED
    }
    
    // Create new visitor
    @objc public func newVisitor(visitorId: String, hasConsented: Bool, instanceType: Instance = .SHARED_INSTANCE) -> FSVisitorBuilder {
        return FSVisitorBuilder(visitorId, hasConsented, instanceType: instanceType)
    }
    
    // Get status
    public func getStatus() -> FSSdkStatus {
        return currentStatus
    }
    
    // Update status
    func updateStatus(_ newStatus: FSSdkStatus) {
        // _ if the staus has not changed then no need to trigger the callback
        if newStatus == currentStatus {
            return
        }
        // Update the status
        currentStatus = newStatus
        // Trigger the callback
        if let callbackListener = currentConfig.onSdkStatusChanged {
            callbackListener(newStatus)
        }
    }
    
    // When close is called will trigger all hits present in batch
    @objc public func close() {
        Flagship.sharedInstance.sharedVisitor?.configManager.trackingManager?.batchManager.batchFromQueue()
    }
}
