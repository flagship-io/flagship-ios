//
//  FSTracking.swift
//  FlagShip
//
//  Created by Adel on 13/08/2019.
//

import Foundation


public enum FSTypeTrack: String {
    
    case PAGE        = "PAGEVIEW"
    case TRANSACTION = "TRANSACTION"
    case ITEM        = "ITEM"
    case EVENT       = "EVENT"
    
    case None   = "None"
    
    
}


public enum FSCategoryEvent: Int {
    
    case Action_Tracking     = 1
    case User_Engagement     = 2
    
    
    
    public var categoryString:String{
        
        switch self {
        case .Action_Tracking:
            return "Action Tracking"
        case .User_Engagement:
            return "User Engagement"
        }
    }
}






public protocol FSTrackingProtocol {
    
    var type:FSTypeTrack { get }
    
    var bodyTrack:Dictionary<String,Any>? { get }
    
}

public class FSTracking :FSTrackingProtocol{
    
    // Here will add all commun args
    
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
    
    
    override init() {
        
        super.init()
        self.type = .PAGE
    }
}


//
//// Visitor Event
//public class FSVisitorTrack:FSTracking{
//
//
//
//}

// Transaction
public class FSTransactionTrack:FSTracking{
    
    // Required
    var transactionId:String!
    var affiliation:String!
    
    // Optional
    var revenue:Double?
    var shipping:Double?
    var tax:Double?
    var currency:String?
    var couponCode:String?
    var paymentMethod:String?
    var ShippingMethod:String?
    var itemCount:Int?
    
    
    public init(_ transactionId:String!, _ affiliation:String!) {
        
        super.init()
        
        self.type          = .TRANSACTION
        
        self.affiliation   = affiliation
  
    }
    
    
    public  override var bodyTrack: Dictionary<String, Any>?{
        
        get {
            
            return nil
        }
        
    }
    
}


///////////////////////////////////// Item ///////////////////////////////////////

public class FSItemTrack:FSTracking{
    
    
    var transactionId:String!
    var name:String!
    var price:Double?
    var quantity:Int?
    var code:String?
    var category:String?
    
    
    public init(_ transactionId:String!, _ name:String!) {
        
        super.init()
        
        self.type          = .ITEM
        self.transactionId = transactionId
        self.name          = name
        self.price         = nil
        self.quantity      = nil
        self.code          = nil
        self.category      = nil
    }
    
    
    
    public init(_ transactionId:String!, _ name:String!, _ price:Double?, _ quantity:Int?, _ code: String?, _ category:String? ) {
        
        super.init()
        
        self.type          = .ITEM
        self.transactionId = transactionId
        self.name          = name
        self.price         = price
        self.quantity      = quantity
        self.code          = code
        self.category      = category
    }
    
    
    public  override var bodyTrack: Dictionary<String, Any>?{
        
        get {
            
            return nil
        }
        
    }
}


// //////////////////////////  Event ////////////////////////////////:
public class FSEventTrack:FSTracking{
    
    var category:FSCategoryEvent!
    var ation:String!
    var label:String?
    var value:Double?
    
    
    public init(_ eventCategory:FSCategoryEvent, _ eventAction:String, _ eventLabel:String?, _ eventValue:Double) {
        
    
        super.init()  /// Set dans la base les element vitales
        
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.ation = eventAction
 
        self.label = eventLabel
        
        self.value = eventValue
        
    }
    
    public init(_ eventCategory:FSCategoryEvent, _ eventAction:String){
        
        super.init()  /// Set dans la base les element vitales
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.ation = eventAction
        
        self.label = nil
        
        self.value = nil
    }
    
    
    public  override var bodyTrack: Dictionary<String, Any>?{
        
        get {
            /// Refractor later this part
            if (self.label != nil && self.value != nil){
                return ["cid":self.clientId,
                        "t"  :self.type.rawValue,
                        "ec" : self.category.categoryString,
                        "vid":self.visitorId,
                        "ea" :self.ation,
                        "el" :self.label ,
                        "ev" :self.value,
                        "ds" :self.dataSource,
                        "cst":Int64(exactly: Date.timeIntervalBetween1970AndReferenceDate) as Any]
            }else{
                return ["cid":self.clientId,
                        "t"  :self.type.rawValue,
                        "ec" : self.category.categoryString,
                        "vid":self.visitorId,
                        "ea" :self.ation,
                        "ds" :self.dataSource,
                        "cst":Int64(exactly: Date.timeIntervalBetween1970AndReferenceDate) as Any]
            }
        }

    }
}
