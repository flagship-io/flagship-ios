//
//  ABFlagShip.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation

public class ABFlagShip:NSObject{
    
    // This id is unique for the app
    var visitorId:String?
    
    // Client Id
    var clientId:String!
    
    // Current Context
    var context:FSContext!
    
    
    // All Campaigns
    var campaigns:FSCampaigns!
    
    
    // Service
    var service:ABService!
    
    // Enable Logs, By default is equal to True
    public var enableLogs:Bool = true
    
    
    // Panic Button
    public var disabledSdk:Bool = false
    
    public static let sharedInstance:ABFlagShip = {
        
        let instance = ABFlagShip()
        // setup code
        return instance
    }()
    
    
    override init() {
        // init context
        self.context = FSContext()
    }
    
    
    
     public func startFlagShip(_ visitorId:String?, onFlagShipReady:@escaping(FlagshipState)->Void){
        do {
            try self.readClientIfFromPlist()    // Read EnvId from plist
            
        }catch{
            
            onFlagShipReady(FlagshipState.NotReady)
            
            FSLogger.FSlog("Can't find Environment Id in plist",.Campaign)
            
            return
        }
        // set visitor Id
        self.visitorId = visitorId
        // Get All Campaign for the moment
        self.service = ABService(self.clientId, self.visitorId ?? "")
        
        // Au départ mettre a dispo les campaigns du cache.
        self.campaigns =  self.service.cacheManager.readCampaignFromCache()
        self.context.updateModification(self.campaigns)
        
        // Mettre à jour les campaigns
        self.service.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                // Set Campaigns
                self.campaigns = campaigns
                self.context.updateModification(campaigns)
                onFlagShipReady(FlagshipState.Ready)
            }else{
                onFlagShipReady(FlagshipState.NotReady)
            }
        }
        
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
            self.service.offLineTracking.flushStoredEvents()
        })
    }
    
    
    public func getCampaigns(onGetCampaign:@escaping(FlagshipError?)->Void){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
        }
        
        
        FSLogger.FSlog("Get Campaign .............", .Campaign)
        
        self.service.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                
                // Set Campaigns
                self.campaigns = campaigns
                self.context.updateModification(campaigns)
                
                FSLogger.FSlog(String(format: "The get Campaign are %@", campaigns.debugDescription), .Campaign)

                onGetCampaign(nil)
                
            }else{
                
                FSLogger.FSlog(String(format: "Error on get campaign", campaigns.debugDescription), .Campaign)

                onGetCampaign(.GetCampaignError)
            }
        }
    }
    
    
    ////////////// Update Context /////////////////////////:
    // sync
    public func updateContext(_ contextvalues:Dictionary<String,Any>, sync:((FlagshipState)->Void)?){
        
        
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
            
            throw FlagshipError.BadPlist
        }
        print(cId)
        
        self.clientId = cId
    }
    
    
    
    /////////////////////////////////////// SHIP VALUES /////////////////////////////////////////////////
    
    // Bool
    public func getModification(_ key:String, defaultBool:Bool, activate:Bool) -> Bool {
        
        // Check if disabled
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return defaultBool
        }
        
        if activate{
            // Activate
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        
        return context.readBooleanFromContext(key, defaultBool: defaultBool)
        
        
        
    }
    
    // String
    public func getModification(_ key:String, defaultString:String, activate:Bool) -> String{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return defaultString
        }

        
        if activate && self.campaigns != nil {
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readStringFromContext(key, defaultString: defaultString)
    }
    
    /// Double
    public func getModification(_ key:String, defaultDouble:Double, activate:Bool) -> Double{
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return defaultDouble
        }

        
        if activate && self.campaigns != nil{
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readDoubleFromContext(key, defaultDouble: defaultDouble)
    }
    
    // Float
    public func getModification(_ key:String, defaulfloat:Float, activate:Bool) -> Float{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return defaulfloat
        }

        
        if activate && self.campaigns != nil{
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        return context.readFloatFromContext(key, defaultFloat: defaulfloat)
    }
    // Integer
    public func getModification(_ key:String, defaultInt:Int, activate:Bool) -> Int{
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return defaultInt
        }
        
        if activate && self.campaigns != nil {
            
            self.service.activateCampaignRelativetoKey(key,self.campaigns)
        }
        
        return context.readIntFromContext(key, defaultInt: defaultInt)
    }
    
    
    //////////////////////////// UPDATE CONTEXT ////////////////////////
    
    public func updateContext(_ newValue:[String:(String,Int,Float,Bool,Double)]){
        
        self.context.currentContext.merge(newValue) { (_, new) in new }
    }
    
    
    
    ///////////////////////////// Get update Modifications //////////////////////
    
    public func updateFlagsModifications( onFlagUpdateDone:@escaping(FlagshipState)->Void){
        
        if disabledSdk{
            
            FSLogger.FSlog("Flag Ship Disabled", .Campaign)
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
    
    
    
    /////////////////////////// Send EVENT TRACKING /////////////////////////////////
    
    public func sendTracking<T: FSTrackingProtocol>(_ event:T){
        
        if disabledSdk{
            FSLogger.FSlog("Flag Ship Disabled", .Campaign)
            return
        }
        self.service.sendTracking(event)
    }
}
