//
//  Flagship.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.

import Foundation


@objc public enum FStatus: NSInteger {
    
    /// Flagship SDK has not been started or initialized successfully.
    case NOT_INITIALIZED = 0x0
    
    /// Flagship SDK has been started successfully but is still polling campaigns.
    case POLLING         = 0x10
    
    /// Flagship SDK is ready but is running in Panic mode: All features are disabled except the one which refresh this status.
    case PANIC_ON        = 0x20
    
    /// Flagship SDK is ready to use.
    case READY           = 0x100
}

 


public class Flagship:NSObject{
    
    /// envId
    var envId:String?
    /// apiKey
    var apiKey:String?
    /// Configuration
    var currentConfig:FlagshipConfig = FSConfigBuilder().build()
    /// Current visitor
    public private (set) var sharedVisitor:FSVisitor?
    /// Current status
    internal var currentStatus:FStatus = .NOT_INITIALIZED
    
    /// Enabale Log
    var enableLogs:Bool = true
    
    
    
    /// Shared instace
    @objc public static let sharedInstance: Flagship = {
        let instance = Flagship()
        // setup code
        return instance
    }()
    
    private override init(){
    }
    
   @objc public func start(envId:String, apiKey:String, config:FlagshipConfig = FSConfigBuilder().build()){
        
        // Check the environmentId
        if FSTools.chekcXidEnvironment(envId) {
            
            self.envId =   envId
            
        } else {
            self.currentStatus = .NOT_INITIALIZED
            FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay:FSLogMessage.ERROR_INIT_SDK)
            return
        }
        
        /// Set the apiKey
        self.apiKey = apiKey
        
        /// Set configuration
        self.currentConfig = config
        
        /// If the mode bucketing we set the mode at NotReady, until the polling get the
        self.currentStatus = (config.mode == .DECISION_API) ? .READY:.POLLING
        

        FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay:FSLogMessage.INIT_SDK(FlagShipVersion))
    }
    
    
    internal func newVisitor(_ visitorId:String, context:[String:Any] = [:], hasConsented:Bool = true, isAuthenticated:Bool ) -> FSVisitor {

        let newVisitor = FSVisitor(aVisitorId: visitorId, aContext: context, aConfigManager: FSConfigManager(visitorId, config:self.currentConfig), aHasConsented:hasConsented, aIsAuthenticated: isAuthenticated)
        
        /// Define strategy
        newVisitor.strategy = FSStrategy(newVisitor, state:Flagship.sharedInstance.currentStatus)
        
        /// Send consent hit
        newVisitor.sendHitConsent(hasConsented)

        return newVisitor

    }
    
    /// Set the shared visitor 
    public func setSharedVisitor(_ visitor: FSVisitor) {
        
        Flagship.sharedInstance.sharedVisitor = visitor
      }
    
    /// Reset the sdk
    internal func reset(){
        
        sharedVisitor = nil
        currentStatus = .NOT_INITIALIZED
    }
    
    
    /// Create new visitor
    @objc public func newVisitor(_ visitorId:String, instanceType:Instance = .SHARED_INSTANCE)-> FSVisitorBuilder{
        
        return FSVisitorBuilder(visitorId, instanceType: instanceType)
    }
    
    /// Get status
    public func getStatus()->FStatus{
        return currentStatus
    }
    
    
    /// Update status
    internal func updateStatus(_ newStatus:FStatus){
        
        /// _ if the staus has not changed then no need to trigger the callback
        if newStatus == currentStatus{
            return
        }
        
        /// Update the status
        currentStatus = newStatus
        /// Trigger the callback
        if let callbackListener = self.currentConfig.onStatusChanged{
            
            callbackListener(newStatus)
        }
    }
    
}
