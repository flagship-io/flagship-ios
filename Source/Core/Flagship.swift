//
//  ABFlagShip.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation



/**
 
 `FlagShip` class helps you run FlagShip on your native iOS app.
 
 */

public class Flagship:NSObject{
    
    /// This id is unique for the app
    internal(set) public var visitorId:String!
    
    /// Customer id
     internal var fsProfile:FSProfile!
    
    /// Client Id
    internal var environmentId:String!
    
    /// Current Context
    internal var context:FSContext!
    
    
    /// All Campaigns
    internal var campaigns:FSCampaigns!
    
    
    /// Service
    internal var service:ABService?
    
    /// Enable Logs, By default is equal to True
    @objc public var enableLogs:Bool = true
    
    
    /// Panic Button let you disable the SDK if needed
    @objc public var disabledSdk:Bool = false
    
    
    
    internal var sdkModeRunning:FlagshipMode = .DECISION_API  // By default 
    
    
    /// Shared instance
    @objc public static let sharedInstance:Flagship = {
        
        let instance = Flagship()
        // setup code
        return instance
    }()
    
    
    /// Audience
    let audience:FSAudience!
    
    
    private override init() {
        // init context
        self.context = FSContext()
        
        self.audience = FSAudience()
        
    }
    
    
    /**
     Start FlagShip
     
     @param environmentId String environmentId id for client
     
     @param visitorId String visitor id
     
     @param pBlock The block to be invoked when sdk is ready
     */
    
    @available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "Use start(environmentId:String, _ customVisitorId:String?,_ mode:FlagShipMode, completionHandler:@escaping(FlagShipResult)->Void)")
    @objc public func startFlagShip(environmentId:String, _ visitorId:String?, completionHandler:@escaping(FlagshipResult)->Void){
        
        // Checkc the environmentId
        if (FSTools.chekcXidEnvironment(environmentId)){
            
            self.environmentId = environmentId
            
        }else{
            
            completionHandler(.NotReady)
            return
        }
        
        
        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            
        }catch{
            
            completionHandler(.NotReady)
            FSLogger.FSlog(String(format: "The visitor id is empty. The SDK FlagShip is not ready "), .Campaign)
            return
        }
        
        // Get All Campaign for the moment
        self.service = ABService(self.environmentId, self.visitorId)
        
        // Set the préconfigured context
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }

        
        // Add the keys all_users temporary
        self.context.currentContext.updateValue("", forKey:ALL_USERS)
        
        // The current context is
        FSLogger.FSlog("The current context is : \(self.context.currentContext.description)", .Campaign)
        
        
        // Au départ mettre a dispo les campaigns du cache.
        self.campaigns =  self.service?.cacheManager.readCampaignFromCache()
        self.context.updateModification(self.campaigns)
        
        // Mettre à jour les campaigns
        self.service?.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                // Set Campaigns
                
                // Check if the panic button is activated
                if (campaigns?.panic ?? false){
                    
                    // Update the state
                    self.disabledSdk = true
                    FSLogger.FSlog(String(format: "The FlagShip is disabled from the front"), .Campaign)
                    
                    FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)
                    
                    completionHandler(FlagshipResult.Disabled)
                    
                }else{
                    
                    self.disabledSdk = false
                    self.campaigns = campaigns
                    self.context.updateModification(campaigns)
                    completionHandler(FlagshipResult.Ready)
                }
            }else{
                
                FSLogger.FSlog(String(format: "Error on get campaign, the SDK is not ready for use"), .Campaign)
                
                completionHandler(FlagshipResult.NotReady)
            }
        }
        
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
            self.service?.offLineTracking.flushStoredEvents()
        })
    }
    
    
    /**
     getCampaigns
     
     @param pBlock The block to be invoked when sdk receive campaign
     */
    internal func getCampaigns(onGetCampaign:@escaping(FlagshipError?)->Void){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        
        
        FSLogger.FSlog("Get Campaign .............", .Campaign)
        
        if self.service != nil {
            
            self.service?.getCampaigns(context.currentContext) { (campaigns, error) in
                
                if (error == nil){
                    
                    // Check if the sdk is disabled
                    if( campaigns!.panic){
                        
                        self.disabledSdk = true
                        
                        FSLogger.FSlog(String(format: "The FlagShip is disabled from the front"), .Campaign)
                        
                        FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)
                        
                        
                    }else{
                        
                        self.disabledSdk = false
                        // Set Campaigns
                        self.campaigns = campaigns
                        self.context.updateModification(campaigns)
                        FSLogger.FSlog(String(format: "The get Campaign are %@", campaigns.debugDescription), .Campaign)
                        
                    }
                    
                    onGetCampaign(nil)
                }else{
                    
                    FSLogger.FSlog(String(format: "Error on get campaign", campaigns.debugDescription), .Campaign)
                    
                    onGetCampaign(.GetCampaignError)
                }
            }
        }else{
            
            onGetCampaign(.GetCampaignError)
        }
    }
    
    
    
    /**
     Update Context
     
     @param contextvalues Dictionary that represent keys value relative to users
     
     @param sync This block is invoked when updating context done and ready to use a new modification  ... this block can be nil
     
     */
    
    @available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "synchronizeModifications(completion:@escaping((FlagShipResult)->Void))")
    @objc public func updateContext(_ contextValues:Dictionary<String,Any>, sync:((FlagshipResult)->Void)?){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        FSLogger.FSlog("Update context", .Campaign)
        
        self.context.currentContext.merge(contextValues) { (_, new) in new }
        if sync !=  nil {
            
            self.getCampaigns { (error) in
                
                if (error == nil){
                    
                    sync!(.Updated)
                    
                }else{
                    
                    sync!(.NotReady)
                }
            }
        }
    }
    
    
    /**
     Update Context with Pre defined keys
     
     @param configuredKey FSAudiences Enum for pre defined keys
     
     @param sync This block is invoked when updating context done and ready to use a new modification  ... this block can be nil
     
     */
    @available(iOS, introduced: 1.1.0, deprecated: 1.2.0, message:  "use updateContext(configuredKey:FSAudiences, value:Any)")
    public func updateContextWithPreConfiguredKeys(_ configuredKey:FSAudiences, value:Any,sync:((FlagshipResult)->Void)?){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        
        //Check the validity value
        
        if (!configuredKey.chekcValidity(value)){
            
            FSLogger.FSlog(" Skip updating the context with pre configured key \(configuredKey) ..... the value is not valid", .Campaign)
            
        }
        
        FSLogger.FSlog(" Update context with pre configured key", .Campaign)
        
        
        self.context.currentContext.updateValue(value, forKey:configuredKey.rawValue)
        
        
        if sync !=  nil {
            
            self.getCampaigns { (error) in
                
                if (error == nil){
                    
                    sync!(.Updated)
                    
                }else{
                    
                    sync!(.NotReady)
                    
                }
            }
            
        }
    }
    
    
    
    /////////////////////////////////////// SHIP VALUES /////////////////////////////////////////////////
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value to read
     
     @param defaultBool this value will be used when this key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Boolean value
     
     */
    @objc public func getModification(_ key:String, defaultBool:Bool, activate:Bool = false) -> Bool {
        
        // Check if disabled
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultBool
        }
 
        if activate && self.campaigns != nil{
            // Activate
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
        
        return context.readBooleanFromContext(key, defaultBool: defaultBool)
    }
    
    
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value
     
     @param defaultString will be used when the key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return String value
     
     */
    @objc public func getModification(_ key:String, defaultString:String, activate:Bool = false) -> String{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultString
        }
        
        
        if activate && self.campaigns != nil {
            
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readStringFromContext(key, defaultString: defaultString)
    }
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value
     
     @param defaultDouble will be used when the key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Double value
     */
    @objc public func getModification(_ key:String, defaultDouble:Double, activate:Bool = false) -> Double{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultDouble
        }
        
        
        if activate && self.campaigns != nil{
            
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readDoubleFromContext(key, defaultDouble: defaultDouble)
    }
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value
     
     @param defaulfloat will be used when the key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Float value
     */
    @objc public func getModification(_ key:String, defaulfloat:Float, activate:Bool = false) -> Float{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaulfloat
        }
        
        
        if activate && self.campaigns != nil{
            
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readFloatFromContext(key, defaultFloat: defaulfloat)
    }
    
    
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value to read
     
     @param defaultInt this value will be used when this key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Int value
     
     */
    @objc public func getModification(_ key:String, defaultInt:Int, activate:Bool = false) -> Int{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value ", .Campaign)
            return defaultInt
        }
        
        if activate && self.campaigns != nil {
            
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
        
        return context.readIntFromContext(key, defaultInt: defaultInt)
    }
    
    
    /*
     Get modification infos.  { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”}
     */
    @objc public func getModificationInfos(_ key:String) -> [String:String]? {
        
        
        if self.campaigns != nil {
            
            return self.campaigns.getRelativekeyModificationInfos(key)
        }
        
        FSLogger.FSlog(" Any campaign founded, to get the information's modification key", .Campaign) /// See later for the logs
        return nil
    }
    
    
    
    
    /**
     Activate Modifications values
     
     @key key which identifies the modification
     
     */
    
    @objc public func activateModification(key:String){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... activate will not be sent", .Campaign)
            return
            
        }
        
        if self.campaigns != nil {
            
            self.service?.activateCampaignRelativetoKey(key,self.campaigns)
        }
    }
    
    
    /**
     Send Events for tracking data
     
     @param event Event Object (Page, Transaction, Item, Event)
     
     */
    @available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "use sendHit")
    public func sendTracking<T: FSTrackingProtocol>(_ event:T){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(event)
    }
    
    
    /**
     Send Hit for tracking data
     
     @param event Event Object (Page, Transaction, Item, Event)
     
     */
    public func sendHit<T: FSTrackingProtocol>(_ event:T){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(event)
    }
    
    
    
    
    
    
    
    /// For Objective C Project, use the functions below to send Events
    /// See https://developers.flagship.io/ios/#hit-tracking
    
    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */
    
    @objc public func sendTransactionEvent(_ transacEvent:FSTransaction){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Transaction will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(transacEvent)
    }
    
    
    /**
     Send Page event
     
     @param pageEvent : Page event
     
     */
    @objc public func sendPageEvent(_ pageEvent:FSPage){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Page will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(pageEvent)
    }
    
    
    
    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */
    
    @objc public func sendItemEvent(_ itemEvent:FSItem){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Item will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(itemEvent)
    }
    
    
    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    @objc public func sendEventTrack(_ eventTrack:FSEvent){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Track will not be sent", .Campaign)
            return
        }
        self.service?.sendTracking(eventTrack)
    }
    
    
    /**
     This function use to reset the id flagShip
     Should called before start.... to take effect
     See with team to define how to set this function
     */
    
    public func resetUserIdFlagShip(){
        
        FSGenerator.resetFlagShipIdInCache()
    }
    
    
    
}
