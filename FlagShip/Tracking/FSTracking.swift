//
//  FSTracking.swift
//  FlagShip
//
//  Created by Adel on 13/08/2019.
//

import Foundation


public enum FSTypeTrack: Int {
    
    case PAGE        = 1
    case VISITOR     = 2
    case TRANSACTION = 3
    case ITEM        = 4
    case EVENT       = 5
    
    case None   = 0
}





public protocol FSTrackingProtocol {
    
    var type:FSTypeTrack { get }
    
    var bodyTrack:Dictionary<String,Any>? { get }
    
    var bodyTrackBis:Dictionary<String,(String,Int,Double, Float, Bool)>? { get }

    
}

public class FSTracking :FSTrackingProtocol{
    public var bodyTrackBis: Dictionary<String, (String, Int, Double, Float, Bool)>?
    
    
    
    public var bodyTrack: Dictionary<String, Any>?{
        
        get {
            
            return ["ttt":2]
        }
    }
    
    
    public var type: FSTypeTrack = .None
    
    
    var clientId :String!
    var visitorId:String!
    var dataSource:String = "APP"
    
    
    init() {
        
        
        clientId = ABFlagShip.sharedInstance.clientId
        visitorId = ABFlagShip.sharedInstance.visitorId
    }
}



// Page
public class FSPageTrack:FSTracking{
    
    
    
    
}



// Visitor Event
public class FSVisitorTrack:FSTracking{
    
    
    
}

// Transaction
public class FSTransactionTrack:FSTracking{
    
    
    
}


// Item
public class FSItemTrack:FSTracking{
    
    
    
}


// Event
public class FSEventTrack:FSTracking{
    
    var category:String!
    var ation:String!
    var label:String?
    var value:Float?
    
    
    public init(_ eventCategory:String, _ eventAction:String, _ eventLabel:String?, _ eventValue:Float) {
        
    
        super.init()  /// Set dans la base les element vitales
        
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.ation = eventAction
 
        self.label = eventLabel
        
        self.value = eventValue
        
    }
    
    public init(_ eventCategory:String, _ eventAction:String){
        
        super.init()  /// Set dans la base les element vitales
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.ation = eventAction
        
        self.label = nil
        
        self.value = nil
    }
    
    
    public  override var bodyTrack: Dictionary<String, Any>?{
        
        get {
            
            return ["cid":self.clientId,"t":"event", "vid":self.visitorId,"ec":self.category, "ea":self.ation, "el":label, "cst":Date.timeIntervalBetween1970AndReferenceDate]
        }
    }
    
    
//    "cid": "{{acountId}}",
//    "dl": "http%3A%2F%2Fabtastylab.com%2F60511af14f5e48764b83d36ddb8ece5a%2F",
//    "ic": "SKU47",
//    "in": "Shoe",
//    "ip": 3.5,
//    "iq": 4,
//    "iv": "Blue",
//    "t": "ITEM",
//    "tid": "OD564",
//    "vid": "18100217380532936",
//    "ds": "APP"
//
    
    
}
