//
//  FSTracking.swift
//  FlagShip
//
//  Created by Adel on 13/08/2019.
//

import Foundation

 /// :nodoc:
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


/// Enumeration that represent Events type
 @objc public enum FSCategoryEvent: NSInteger {
    
    /// Action tracking
    case Action_Tracking     = 1
    
    /// User engagement
    case User_Engagement     = 2
    
    
    /// :nodoc:
    public var categoryString:String{
        
        switch self {
        case .Action_Tracking:
            return "Action Tracking"
        case .User_Engagement:
            return "User Engagement"
        }
    }
}


/// :nodoc:
@objc public protocol FSTrackingProtocol {
    
    var type:FSTypeTrack { get }
    
    var bodyTrack:Dictionary<String,Any> { get }
    
    var fileName:String! { get }
    
    /// Get cst
    func getCst()-> NSNumber?

}

/// :nodoc:
@objcMembers public class FSTracking :NSObject ,FSTrackingProtocol {
    
    
    
    public func getCst() -> NSNumber? {
        
        return NSNumber(floatLiteral: self.currentSessionTimeStamp ?? 0)
    }
    
    
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
    /// Interface Name
    public var interfaceName:String?
    
    /// User Ip
    public var userIp:String?
    /// Screen Resolution
    public var screenResolution:String?
    ///Screen Color Depth
    public var screenColorDepth:String?
    /// User Language
    public var userLanguage:String?
    /// Queue Time
    public var queueTime:Int64?
    /// Current Session Time Stamp
    public var currentSessionTimeStamp:TimeInterval?
    /// Session Number
    public var sessionNumber:NSNumber?
    
    // Custom Dimension .... a voir
    
    // Custom Metric
    //var customMetric:Int?  ..... a voir
    
    // Session Event Number
    public var sessionEventNumber:NSNumber?
    
    
    override init() {
        
        clientId        = Flagship.sharedInstance.environmentId
        customVisitorId = Flagship.sharedInstance.visitorId
 
        
        // Set time Stamps
        self.currentSessionTimeStamp = Date.timeIntervalSinceReferenceDate
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
            communParams.updateValue(self.clientId ?? "", forKey: "cid") //// Rename it
            // Set FlagShip user id Id
            communParams.updateValue(self.customVisitorId ?? "", forKey: "vid")  //// rename it

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



/**
 This hit should be sent each time a visitor arrives on a new interface.
 */
@available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "use FSPage")
/// :nodoc:
@objcMembers public class FSPageTrack:FSTracking{
    
    
    /**
     Init PageTrack object
     
     @param interfaceName String
          
     @return instance object
     */
    
    @objc public init(_ interfaceName:String) {
        
        super.init()
        self.type = .PAGE
        self.interfaceName = interfaceName
    }
    
    
    /// :nodoc:
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

/**

 Represent a hit Transaction
 */
@available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "use FSTransaction")
/// :nodoc:
@objcMembers public class FSTransactionTrack:FSTracking{
    
    /// Transaction unique identifier.
     private var transactionId:String!
    /// Transaction name. Name of the goal in the reporting.
     private var affiliation:String!
    
    
    /// Total revenue associated with the transaction. This value should include any shipping or tax costs
    public var revenue:NSNumber?
    /// Specifies the total shipping cost of the transaction.
    public var shipping:NSNumber?
    
    /// Specifies the total taxes of the transaction.
    public var tax:NSNumber?
    
    /// Specifies the currency used for all transaction currency values. Value should be a valid ISO 4217 currency code.
    public var currency:String?
    
    /// Specifies the coupon code used by the customer for the transaction.
    public var couponCode:String?
    
    /// Specifies the payment method for the transaction.
    public var paymentMethod:String?
    
    /// Specifies the shipping method of the transaction.
    public var ShippingMethod:String?
    
    /// Specifies the number of items for the transaction.
    public var itemCount:NSNumber?
    
    
    
    /**
     Init transaction object
     
     @param transactionId String
     
     @param affiliation String
     
     @return instance object
     */
     public init(transactionId:String, affiliation:String) {
        
        super.init()
        
        self.type          = .TRANSACTION
        
        self.affiliation   = affiliation
        
        self.transactionId = transactionId
  
    }
    
     /// :nodoc:
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

/**
 Represent item with a transaction. It must be sent after the corresponding transaction.
 */
@available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "use FSItem")
/// :nodoc:
@objcMembers public class FSItemTrack:FSTracking{
    
    /// Transaction unique identifier
    private var transactionId:String!
    
    /// Product name
    private var name:String!
    
    /// Specifies the item price
    public var price:NSNumber?
    
    /// Specifies the item quantity
    public var quantity:NSNumber?
    
    /// Specifies the item code or SKU
    public var code:String!
    
    /// Specifies the item category
    public var category:String?
    
    
    /**
     Init Item object
     
     @param transactionId :String
     
     @param name :String
     
     @return instance object
     */
    public init(transactionId:String, name:String, code:String) {
        
        super.init()
        
        self.type          = .ITEM
        self.transactionId = transactionId
        self.name          = name
        self.price         = 0
        self.quantity      = 0
        self.code          = code
        self.category      = nil
    }
    
    
     /// :nodoc:
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


/**
 
 Represents an event
 */
@available(iOS, introduced: 1.0.0, deprecated: 1.2.0, message: "FSEvent")

/// :nodoc:
@objcMembers public class FSEventTrack:FSTracking{
    
    /// category of the event (Action_Tracking or User_Engagement).
    private var category:FSCategoryEvent!
    
    /// name of the event.
    private var action:String?
    
    /// description of the event.
    public  var label:String?
    
    /// value of the event, must be non-negative.
    public  var eventValue:NSNumber?
    
    
    /**
     Init Event object
     
     @param eventCategory :FSCategoryEvent
     
     @param eventAction :String
     
     @return instance object
     */
    public init(eventCategory:FSCategoryEvent, eventAction:String){
        
        super.init()  /// Set dans la base les element vitales
        
        self.type = .EVENT
        
        self.category = eventCategory
        
        self.action = eventAction
        
        self.label = nil
        
        self.eventValue = nil
    }
    
     /// :nodoc:
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


