//
//  ABFlagShip.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation

public class ABFlagShip:NSObject{
    
    // This id is unique for the app
    var visitorId:String!
    
    // Client Id
    var clientId:String!
    
    // Current Context
    var context:FSContext!
    
    
    // All Campaigns
    var campaigns:FSCampaigns!
    
    
    // Service
    var service:ABService!
    
    public static let sharedInstance:ABFlagShip = {
        
        let instance = ABFlagShip()
        // setup code
        return instance
    }()
    
    
    override init() {
        // init context
        self.context = FSContext()
    }
    
    
    
    /// Init With Id /////
    
    public func startFlagShip(_ visitorId:String, onFlagShipReady:@escaping(FlagshipState)->Void){
        do {
            try self.readClientIfFromPlist()
            
        }catch{
            
            onFlagShipReady(FlagshipState.NotReady)
            
            print("Can't find client Id in plist")
            
            return
        }
        // set visitor Id
        self.visitorId = visitorId
        // Get All Campaign for the moment
        self.service = ABService(self.clientId, self.visitorId)
        
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
        
        self.service.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                
                // Set Campaigns
                self.campaigns = campaigns
                self.context.updateModification(campaigns)
                onGetCampaign(nil)
                
            }else{
                
                onGetCampaign(.GetCampaignError)
            }
        }
    }
    
    
    public func updateContext(_ contextvalues:Dictionary<String,Any>, _ sync:Bool, onSyncIsDone:@escaping(FlagshipState)->Void){
        
        self.context.currentContext.merge(contextvalues) { (_, new) in new }
        
        if (sync){
            
            self.getCampaigns { (error) in
                
                if (error == nil){
                    
                    onSyncIsDone(.Updated)
                    
                }else{
                    
                    onSyncIsDone(.NotReady)
                }
            }
        }
    }
    
    
    
    
    private func readClientIfFromPlist() throws{
        
        guard let cId =   Bundle.main.object(forInfoDictionaryKey: "FlagShipClientId") as? String else{
            
            throw FlagshipError.BadPlist
        }
        print(cId)
        
        self.clientId = cId
    }
    
    
    
    /////////////////////////////////////// SHIP VALUES /////////////////////////////////////////////////
    
    // Bool
    public func shipBooleanValue(_ key:String, defaultBool:Bool, printModification:Bool) -> Bool {
        
        if printModification{
            // Activate
            self.service.activateCampaignRelativetoKey(key,campaigns)
        }
        
        return context.readBooleanFromContext(key, defaultBool: defaultBool)
        
        
        
    }
    
    // String
    public func shipStringeValue(_ key:String, defaultString:String, printModification:Bool) -> String{
        
        if printModification{
            
            self.service.activateCampaignRelativetoKey(key,campaigns)
        }
        return context.readStringFromContext(key, defaultString: defaultString)
    }
    
    /// Double
    public func shipDoubleValue(_ key:String, defaultDouble:Double, printModification:Bool) -> Double{
        
        if printModification{
            
            self.service.activateCampaignRelativetoKey(key,campaigns)
        }
        return context.readDoubleFromContext(key, defaultDouble: defaultDouble)
    }
    
    // Float
    public func shipFloatValue(_ key:String, defaulfloat:Float, printModification:Bool) -> Float{
        
        if printModification{
            
            self.service.activateCampaignRelativetoKey(key,campaigns)
        }
        return context.readFloatFromContext(key, defaultFloat: defaulfloat)
    }
    // Integer
    public func shipIntValue(_ key:String, defaultInt:Int, printModification:Bool) -> Int{
        
        if printModification{
            
            self.service.activateCampaignRelativetoKey(key,campaigns)
        }
        
        return context.readIntFromContext(key, defaultInt: defaultInt)
    }
    
    
    //////////////////////////// UPDATE CONTEXT ////////////////////////
    
    public func updateContext(_ newValue:[String:(String,Int,Float,Bool,Double)]){
        
        self.context.currentContext.merge(newValue) { (_, new) in new }
    }
    
    
    
    ///////////////////////////// Get update Modifications //////////////////////
    
    public func updateFlagsModifications( onFlagUpdateDone:@escaping(FlagshipState)->Void){
        
        
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
        
        // In the futur  If panic Buttton ......... here block the operation
        
        self.service.sendTracking(event)
    }
}
