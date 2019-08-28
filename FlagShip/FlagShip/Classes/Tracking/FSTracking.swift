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
    
    var bodyTrack:Dictionary<String,Any> { get }
    
    var fileName:String! { get }
}

public class FSTracking :FSTrackingProtocol{
    
    
    public var fileName: String! {
        
        get {
            
            let formatDate = DateFormatter()
            formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
            return String(format: "%@.json",formatDate.string(from: Date()))
        }
    }
    
    
    // Here will add all commun args
    public var type: FSTypeTrack = .None
    
    // Required
    var clientId :String!
    var visitorId:String!
    var dataSource:String = "APP"
    
    // Optional
    
    // User Ip
    public var userIp:String?
    // Screen Resolution
    public var screenResolution:String?
    // Screen Color Depth
    public var screenColorDepth:String?
    // User Language
    public var userLanguage:String?
    // Queue Time
    public var queueTime:Int?
    // Time Stamp
    public var currentSessionTimeStamp:Int64?
    // Session Number
    public var sessionNumber:Int?
    
    // Custom Dimension .... a voir
    
    // Custom Metric
    //var customMetric:Int?  ..... a voir
    
    // Session Event Number
    public var sessionEventNumber:Int?
    
    
    init() {
        
        clientId = ABFlagShip.sharedInstance.clientId
        visitorId = ABFlagShip.sharedInstance.visitorId
        
        // Set time Stamps
        self.currentSessionTimeStamp = Int64(exactly: Date.timeIntervalBetween1970AndReferenceDate)
    }
    
    public var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            return [:]
        }
    }
    
    
    public var communBodyTrack:Dictionary<String,Any> {
        
        get {
            
             var communParams:Dictionary<String,Any> = Dictionary<String,Any>()
            // Set Client Id
            communParams.updateValue(self.clientId, forKey: "cid")
            // Set Visitor Id
            communParams.updateValue(self.visitorId, forKey: "vid")
            // Set Data source
            communParams.updateValue(self.dataSource, forKey: "ds")
            // Set User ip
            if (self.userIp != nil) {
                communParams.updateValue(self.userIp ?? "", forKey: "uip")
            }
            // Set Resolution Screen
            if (self.screenResolution != nil) {
                communParams.updateValue(self.screenResolution ?? "", forKey: "sr")
            }
            //Set  Screen Color Depth
            if (self.screenColorDepth != nil) {
                communParams.updateValue(self.screenColorDepth ?? "", forKey: "sd")
            }
            // User Language
            if (self.userLanguage != nil) {
                communParams.updateValue(self.userLanguage ?? "", forKey: "ul")
            }
            // Queue Time
            if (self.queueTime != nil) {
                communParams.updateValue(self.queueTime ?? 0, forKey: "qt")
            }
            // Time Stamp
            communParams.updateValue(self.currentSessionTimeStamp ?? 0, forKey: "cst")
            // Session Number
            if (self.sessionNumber != nil) {
                communParams.updateValue(self.sessionNumber ?? 0, forKey: "sn")
            }
            return communParams
        }
    }
}



// Page
public class FSPageTrack:FSTracking{
    
    
   public override init() {
        
        super.init()
        self.type = .PAGE
    }
    
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            return communBodyTrack
        }
        
    }
}

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
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            
            // Set transactionId
            if self.transactionId != nil{
                customParams.updateValue(self.transactionId ?? "", forKey: "tid")
            }
            // Set affiliation
            if self.affiliation != nil{
                customParams.updateValue(self.affiliation ?? ""  , forKey: "in")
            }
            // Set price
            if self.revenue != nil{
                customParams.updateValue(self.revenue ?? 0, forKey: "ip")
            }
            // Set shipping
            if self.shipping != nil{
                customParams.updateValue(self.shipping ?? 0  , forKey: "iq")
            }
            // Set Tax
            if self.tax != nil{
                customParams.updateValue(self.tax ?? 0, forKey: "ic")
            }
            // Set currency
            if self.currency != nil{
                customParams.updateValue(self.currency ?? "" , forKey: "iv")
            }
            // Set couponCode
            if self.couponCode != nil{
                customParams.updateValue(self.couponCode ?? "" , forKey: "iv")
            }
            // Set paymentMethod
            if self.paymentMethod != nil{
                customParams.updateValue(self.paymentMethod ?? "" , forKey: "iv")
            }
            // Set ShippingMethod
            if self.ShippingMethod != nil{
                customParams.updateValue(self.ShippingMethod ?? "" , forKey: "iv")
            }
            //Set itemCount
            if self.itemCount != nil{
                customParams.updateValue(self.itemCount ?? 0 , forKey: "iv")
            }
            
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            
            return customParams
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
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            
            // Set transactionId
            if self.transactionId != nil{
                customParams.updateValue(self.transactionId ?? "", forKey: "tid")
            }
            // Set name
            if self.name != nil{
                customParams.updateValue(self.name ?? ""  , forKey: "in")
            }
            // Set price
            if self.price != nil{
                customParams.updateValue(self.price ?? 0, forKey: "ip")
            }
            // Set quantity
            if self.quantity != nil{
                customParams.updateValue(self.quantity ?? 0  , forKey: "iq")
            }
            // Set code
            if self.code != nil{
                customParams.updateValue(self.code ?? "", forKey: "ic")
            }
            // Set category
            if self.category != nil{
                customParams.updateValue(self.category ?? "" , forKey: "iv")
            }
            
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            
            return customParams

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
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            // Set category
            customParams.updateValue(self.category.categoryString, forKey:"sc")
            // Set Type
            customParams.updateValue(self.type.rawValue, forKey: "t")
            // Set Action
            customParams.updateValue(self.ation, forKey: "ea")
            // Set Label
            if self.label != nil{
                customParams.updateValue(self.label ?? "", forKey: "el")
            }
            // Set Value
            if self.value != nil{
                customParams.updateValue(self.value ?? 0  , forKey: "ev")
            }
            // Merge the commun params
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            
            return customParams
            
        }

    }
}
