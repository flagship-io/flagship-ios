//
//  ABFlagShip.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation



/**
 
 `ABFlagShip` class helps you run FlagShip on your native iOS app.
 
 */

public class ABFlagShip:NSObject{
    
    // This id is unique for the App
    var visitorId:String?
    
    
    // Client Id
    internal var environmentId:String!
    
    // Current Context
    internal var context:FSContext!
    
    
    // All Campaigns
    private var campaigns:FSCampaigns!
    
    
    // Service
    var service:ABService!
    
    /// Enable Logs, By default is equal to True
    @objc public var enableLogs:Bool = true
    
    
    /// Panic Button let you disable the SDK if needed
    @objc public var disabledSdk:Bool = false
    
    
    /// Shared instance
    @objc public static let sharedInstance:ABFlagShip = {
        
        let instance = ABFlagShip()
        // setup code
        return instance
    }()
    
    
    private override init() {
        // init context
        self.context = FSContext()
    }
    
    
    /**
     Start FlagShip
     
     @param visitorId String visitor id
     
     @param pBlock The block to be invoked when sdk is ready
     */
    @objc public func startFlagShip(environmentId:String, _ visitorId:String?, onFlagShipReady:@escaping(FlagshipState)->Void){
        
        // Checkc the environmentId
        if (FSTools.chekcXidEnvironment(environmentId)){
            
            self.environmentId = environmentId
            
        }else{
            
            onFlagShipReady(.NotReady)
            return
        }
        
        
        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            
        }catch{
            
            onFlagShipReady(.NotReady)
            FSLogger.FSlog(String(format: "The visitor id is empty. The SDK FlagShip is not ready "), .Campaign)
            return
        }
        
        // Get All Campaign for the moment
        self.service = ABService(self.environmentId, self.visitorId ?? "")
        
        // Au départ mettre a dispo les campaigns du cache.
        self.campaigns =  self.service.cacheManager.readCampaignFromCache()
        self.context.updateModification(self.campaigns)
        
        // Mettre à jour les campaigns
        self.service.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                // Set Campaigns
                
                // Check if the panic button is activated
                if (campaigns?.panic ?? false){
                    
                    // Update the state
                    self.disabledSdk = true
                    FSLogger.FSlog(String(format: "The FlagShip is disabled from the front"), .Campaign)
                    
                    FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)

                    onFlagShipReady(FlagshipState.Disabled)
                    
                }else{
                    
                    self.disabledSdk = false
                    self.campaigns = campaigns
                    self.context.updateModification(campaigns)
                    onFlagShipReady(FlagshipState.Ready)
                }
            }else{
                onFlagShipReady(FlagshipState.NotReady)
            }
        }
        
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
            self.service.offLineTracking.flushStoredEvents()
        })
    }
    
    
    /**
     getCampaigns
     
     @param pBlock The block to be invoked when sdk receive campaign
     */
    public func getCampaigns(onGetCampaign:@escaping(FlagshipError?)->Void){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        
        
        FSLogger.FSlog("Get Campaign .............", .Campaign)
        
        if self.service != nil {
            
            self.service.getCampaigns(context.currentContext) { (campaigns, error) in
                
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
    @objc public func updateContext(_ contextvalues:Dictionary<String,Any>, sync:((FlagshipState)->Void)?){
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        FSLogger.FSlog("Update context", .Campaign)
        self.context.currentContext.merge(contextvalues) { (_, new) in new }
        
        
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
    
    
    private func readClientIfFromPlist() throws{
        
        guard let cId =   Bundle.main.object(forInfoDictionaryKey: "FlagShipEnvId") as? String else{
            
            throw FSError.BadPlist
          
        }
        print(cId)
        
        self.environmentId = cId
    }
    
    
    
    /////////////////////////////////////// SHIP VALUES /////////////////////////////////////////////////
    
    /**
     Get Modification from the decision api
     
     @param key for associated to value to read
     
     @param defaultBool this value will be used when this key don't exist
     
     @param activate if ture, the sdk send automaticaly an activate event. if false you have to do it manualy
     
     @return Boolean value

     */
    @objc public func getModification(_ key:String, defaultBool:Bool, activate:Bool) -> Bool {
        
        // Check if disabled
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultBool
        }
        
        if activate{
            // Activate
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
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
    @objc public func getModification(_ key:String, defaultString:String, activate:Bool) -> String{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultString
        }

        
        if activate && self.campaigns != nil {
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
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
    @objc public func getModification(_ key:String, defaultDouble:Double, activate:Bool) -> Double{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaultDouble
        }

        
        if activate && self.campaigns != nil{
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
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
    @objc public func getModification(_ key:String, defaulfloat:Float, activate:Bool) -> Float{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value", .Campaign)
            return defaulfloat
        }

        
        if activate && self.campaigns != nil{
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
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
    @objc public func getModification(_ key:String, defaultInt:Int, activate:Bool) -> Int{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled ... will return a default value ", .Campaign)
            return defaultInt
        }
        
        if activate && self.campaigns != nil {
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        
        return context.readIntFromContext(key, defaultInt: defaultInt)
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
             
             self.service.activateCampaignRelativetoKey(key,self.campaigns)
         }
    }
    
    
    
    /**
     Update Modifications values
     
     @onFlagUpdateDone this block will be invoked when the update done
     
     */
    @objc public func updateFlagsModifications( onFlagUpdateDone:@escaping(FlagshipState)->Void){
        
        if disabledSdk{
            
            FSLogger.FSlog("FlagShip Disabled", .Campaign)
            return
        }
        
        self.service.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                // Set Campaigns
                self.campaigns = campaigns
                self.context.updateModification(campaigns)
                onFlagUpdateDone(FlagshipState.Ready)
                
            }else{
                onFlagUpdateDone(FlagshipState.NotReady)
            }
        }
    }
    
    
    
    /**
     Send Events for tracking data
     
     @param event Event Object (Page, Transaction, Item, Event)
     
     */
     public func sendTracking<T: FSTrackingProtocol>(_ event:T){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event will not be sent", .Campaign)
            return
        }
        self.service.sendTracking(event)
    }
    
    /// For Objective C Project, use the functions below to send Events
    /// See https://developers.flagship.io/ios/#hit-tracking

    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */
    
    @objc public func sendTransactionEvent(_ transacEvent:FSTransactionTrack){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Transaction will not be sent", .Campaign)
            return
        }
        self.service.sendTracking(transacEvent)
    }
    
    
    /**
     Send Page event
     
     @param pageEvent : Page event
     
     */
    @objc public func sendPageEvent(_ pageEvent:FSPageTrack){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Page will not be sent", .Campaign)
            return
        }
        self.service.sendTracking(pageEvent)
    }
    
    
    
    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */
    
    @objc public func sendItemEvent(_ itemEvent:FSItemTrack){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Item will not be sent", .Campaign)
            return
        }
        self.service.sendTracking(itemEvent)
    }
    
    
    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    @objc public func sendEventTrack(_ eventTrack:FSEventTrack){
        
        if disabledSdk{
            FSLogger.FSlog("FlagShip Disabled.....The event Track will not be sent", .Campaign)
            return
        }
        self.service.sendTracking(eventTrack)
    }
}
