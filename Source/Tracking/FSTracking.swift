//
//  FSTracking.swift
//  FlagShip
//
//  Created by Adel on 13/08/2019.
//

import Foundation


@objc public enum FSTypeTrack:NSInteger {
    
    case PAGE        = 0
    case TRANSACTION
    case ITEM
    case EVENT
    case None
    
    public var typeString:String{

        switch self {
        case .PAGE:
            return "SCREENVIEW"
        case .TRANSACTION:
            return "TRANSACTION"
        case .ITEM:
            return "ITEM"
        case .EVENT:
            return "EVENT"
        case .None:
            return "None"
        }
    }
}


 @objc public enum FSCategoryEvent: NSInteger {
    
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



@objc public protocol FSTrackingProtocol {
    
    var type:FSTypeTrack { get }
    
    var bodyTrack:Dictionary<String,Any> { get }
    
    var fileName:String! { get }
}

@objcMembers public class FSTracking :NSObject ,FSTrackingProtocol {
    
    
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
    var clientId :String?
    var fsUserId:String?
    var customVisitorId:String?
    var dataSource:String = "APP"
    
    // Optional
    // Interface Name
    public var interfaceName:String?
    
    // User Ip
    public var userIp:String?
    // Screen Resolution
    public var screenResolution:String?
    // Screen Color Depth
    public var screenColorDepth:String?
    // User Language
    public var userLanguage:String?
    // Queue Time
    public var queueTime:NSNumber?
    // Time Stamp
    public var currentSessionTimeStamp:Int64?
    // Session Number
    public var sessionNumber:NSNumber?
    
    // Custom Dimension .... a voir
    
    // Custom Metric
    //var customMetric:Int?  ..... a voir
    
    // Session Event Number
    public var sessionEventNumber:NSNumber?
    
    
    override init() {
        
        clientId        = Flagship.sharedInstance.environmentId
        //fsUserId        = FlagShip.sharedInstance.fsProfile.tupleId.fsUserId
        customVisitorId = Flagship.sharedInstance.visitorId
 
        
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
            communParams.updateValue(self.clientId ?? "", forKey: "cid")
            // Set FlagShip user id Id
            communParams.updateValue(self.customVisitorId ?? "", forKey: "vid")

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
            
            // Interface Name
            if (self.interfaceName != nil) {
                communParams.updateValue(self.interfaceName ?? 0, forKey: "dl")
            }
            
            return communParams
        }
    }
}



// Page
@objcMembers public class FSPageTrack:FSTracking{
    
    
    @objc public init(_ interfaceName:String) {
        
        super.init()
        self.type = .PAGE
        self.interfaceName = interfaceName
    }
    
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            
            // Set Type
            customParams.updateValue(self.type.typeString, forKey: "t")
            
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            return customParams
        }
        
    }
}

// Transaction
@objcMembers public class FSTransactionTrack:FSTracking{
    
    // Required
     private var transactionId:String!
     private var affiliation:String!
    
    // Optional
    
     public var revenue:NSNumber?
     public var shipping:NSNumber?
     public var tax:NSNumber?
     public var currency:String?
     public var couponCode:String?
     public var paymentMethod:String?
     public var ShippingMethod:String?
     public var itemCount:NSNumber?
    
    
     public init(transactionId:String, affiliation:String) {
        
        super.init()
        
        self.type          = .TRANSACTION
        
        self.affiliation   = affiliation
        
        self.transactionId = transactionId
  
    }
    
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            
            // Set Type
            customParams.updateValue(self.type.typeString, forKey: "t")

            // Set transactionId
            if self.transactionId != nil{
                customParams.updateValue(self.transactionId ?? "", forKey: "tid")
            }
            // Set affiliation
            if self.affiliation != nil{
                customParams.updateValue(self.affiliation ?? ""  , forKey: "ta")
            }
            // Set price
            if self.revenue != nil{
                customParams.updateValue(self.revenue ?? 0, forKey: "tr")
            }
            // Set shipping
            if self.shipping != nil{
                customParams.updateValue(self.shipping ?? 0  , forKey: "ts")
            }
            // Set Tax
            if self.tax != nil{
                customParams.updateValue(self.tax ?? 0, forKey: "tt")
            }
            // Set currency
            if self.currency != nil{
                customParams.updateValue(self.currency ?? "" , forKey: "tc")
            }
            // Set couponCode
            if self.couponCode != nil{
                customParams.updateValue(self.couponCode ?? "" , forKey: "tcc")
            }
            // Set paymentMethod
            if self.paymentMethod != nil{
                customParams.updateValue(self.paymentMethod ?? "" , forKey: "pm")
            }
            // Set ShippingMethod
            if self.ShippingMethod != nil{
                customParams.updateValue(self.ShippingMethod ?? "" , forKey: "sm")
            }
            //Set itemCount
            if self.itemCount != nil{
                customParams.updateValue(self.itemCount ?? 0 , forKey: "icn")
            }
            
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            
            return customParams
        }
        
    }
    
}


///////////////////////////////////// Item ///////////////////////////////////////

@objcMembers public class FSItemTrack:FSTracking{
    
    
    private var transactionId:String!
    private var name:String!
    public var price:NSNumber?
    public var quantity:NSNumber?
    public var code:String?
    public var category:String?
    
    public init(transactionId:String, name:String) {
        
        super.init()
        
        self.type          = .ITEM
        self.transactionId = transactionId
        self.name          = name
        self.price         = 0
        self.quantity      = 0
        self.code          = nil
        self.category      = nil
    }
    
    
    
//     public init(transactionId:String!,  name:String!, price:NSNumber, quantity:NSNumber, code: String?, category:String? ) {
//
//        super.init()
//
//        self.type          = .ITEM
//        self.transactionId = transactionId
//        self.name          = name
//        self.price         = price
//        self.quantity      = quantity
//        self.code          = code
//        self.category      = category
//    }
//
    
    public  override var bodyTrack: Dictionary<String, Any>{
        
        get {
            
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
           
            // Set Type
            customParams.updateValue(self.type.typeString, forKey: "t")
            
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
@objcMembers public class FSEventTrack:FSTracking{
    
    private var category:FSCategoryEvent!
    private var action:String?
    public  var label:String?
    public  var eventValue:NSNumber?
    
    
    public init(eventCategory:FSCategoryEvent, eventAction:String, eventLabel:String?, eventValue:NSNumber) {
    
        super.init()  /// Set dans la base les element vitales
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.action = eventAction
 
        self.label = eventLabel
        
        self.eventValue = eventValue
        
    }
    
    public init(eventCategory:FSCategoryEvent, eventAction:String){
        
        super.init()  /// Set dans la base les element vitales
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.action = eventAction
        
        self.label = nil
        
        self.eventValue = nil
    }
    
    
    public override var bodyTrack: Dictionary<String, Any>{
        
        get {
            var customParams:Dictionary<String,Any> = Dictionary<String,Any>()
            // Set category
            customParams.updateValue(self.category.categoryString, forKey:"ec")
            // Set Type
            customParams.updateValue(self.type.typeString, forKey: "t")
            // Set Action
            customParams.updateValue(self.action ?? "", forKey: "ea")
            // Set Label
            if self.label != nil{
                customParams.updateValue(self.label ?? "", forKey: "el")
            }
            // Set Value
            if self.eventValue != nil{
                customParams.updateValue(self.eventValue ?? 0  , forKey: "ev")
            }
            // Merge the commun params
            customParams.merge(self.communBodyTrack){  (_, new) in new }
            
            return customParams
            
        }

    }
}
