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
    
    public func startFlagShip(_ visitorId:String, /* _ context:FSContext,*/ onFlagShipReady:@escaping(FlagshipState)->Void){
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
    }
    
    
    private func readClientIfFromPlist() throws{
        
        guard let cId =   Bundle.main.object(forInfoDictionaryKey: "FlagShipClientId") as? String else{
            
            throw FlagshipError.BadPlist
        }
        print(cId)
        
        self.clientId = cId
    }
    
    // Bool
    public func shipBooleanValue(_ key:String, defaultBool:Bool) -> Bool {
        
        return context.readBooleanFromContext(key, defaultBool: defaultBool)
    }
    
    // String
    public func shipStringeValue(_ key:String, defaultString:String) -> String{
        
        return context.readStringFromContext(key, defaultString: defaultString)
    }
    
    /// Double
    public func shipDoubleValue(_ key:String, defaultDouble:Double) -> Double{
        
        return context.readDoubleFromContext(key, defaultDouble: defaultDouble)
    }
    
    // Float
    public func shipFloatValue(_ key:String, defaulfloat:Float) -> Float{
        
        return context.readFloatFromContext(key, defaultFloat: defaulfloat)
    }
    // Integer
    public func shipIntValue(_ key:String, defaultInt:Int) -> Int{
        
        return context.readIntFromContext(key, defaultInt: defaultInt)
    }
}
