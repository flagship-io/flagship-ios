//
//  FSHits.swift
//  Flagship
//
//  Created by Adel on 04/03/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation

/**
 This hit should be sent each time a visitor arrives on a new url page.
 */
@objcMembers public class FSPage: FSTracking {
    /// Location Name where the event occurs
  //  private var location: String?

    /**
     Init Page hit

     @param location String

     @return instance object
     */

    public init(_ location: String) {
        super.init()
        self.type = .PAGE
        self.location = location
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { try super.init(from: decoder) }
        // location
        do { self.location = try values.decode(String.self, forKey: .location) } catch { self.location = "" }
        self.type = .PAGE
    }

    override public func encode(to encoder: Encoder) throws {}

    private enum CodingKeys: String, CodingKey {
        case location = "dl"
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")

        // Location name
//        if self.location != nil {
//            customParams.updateValue(self.location ?? "", forKey: "dl")
//        }

        customParams.merge(self.communBodyTrack) { _, new in new }
        return customParams
    }
}

/**
 This hit should be sent each time a visitor arrives on a new screen.
 */
@objcMembers public class FSScreen: FSTracking {
    /// Location Name where the event occurs
  //  private var location: String?
    /**
     Init Screen hit

     @param location String

     @return instance object
     */

    public init(_ location: String) {
        super.init()
        self.type = .SCREEN
        self.location = location
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { try super.init(from: decoder) }
        // location
        do { self.location = try values.decode(String.self, forKey: .location) } catch { self.location = "" }
        // Set type
        self.type = .SCREEN
    }

    private enum CodingKeys: String, CodingKey {
        case location = "dl"
    }

    override public func encode(to encoder: Encoder) throws {}

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")
        // Location name
       // if self.location != nil { customParams.updateValue(self.location ?? "", forKey: "dl") }
        customParams.merge(self.communBodyTrack) { _, new in new }
        return customParams
    }
}

/**

 Represent a hit Transaction
 */

@objcMembers public class FSTransaction: FSTracking {
    /// Transaction unique identifier.
    private(set) var transactionId: String
    /// Transaction name. Name of the goal in the reporting.
    private(set) var affiliation: String

    /// Total revenue associated with the transaction. This value should include any shipping or tax costs
    public var revenue: NSNumber?
    /// Specifies the total shipping cost of the transaction.
    public var shipping: NSNumber?
    /// Specifies the total taxes of the transaction.
    public var tax: NSNumber?

    /// Specifies the currency used for all transaction currency values. Value should be a valid ISO 4217 currency code.
    public var currency: String?

    /// Specifies the coupon code used by the customer for the transaction.
    public var couponCode: String?

    /// Specifies the payment method for the transaction.
    public var paymentMethod: String?

    /// Specifies the shipping method of the transaction.
    public var shippingMethod: String?

    /// Specifies the number of items for the transaction.
    public var itemCount: NSNumber?

    /**
     Init transaction object

     @param transactionId String

     @param affiliation String

     @return instance object
     */
    public init(transactionId: String, affiliation: String) {
        self.affiliation = affiliation
        self.transactionId = transactionId
        super.init()
        self.type = .TRANSACTION
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // transactionId
        do { self.transactionId = try values.decode(String.self, forKey: .transactionId) } catch { self.transactionId = "" }
        // affiliation
        do { self.affiliation = try values.decode(String.self, forKey: .affiliation) } catch { self.affiliation = "" }
        // revenue
        do { self.revenue = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .revenue)) } catch { /* error on decode revenue*/ }
        // shipping
        do { self.shipping = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .shipping)) } catch { /* "error on deocde shipping */ }
        // tax
        do { self.tax = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .tax)) } catch { /* "error on deocde tax */ }
        // currency
        do { self.currency = try values.decode(String.self, forKey: .currency) } catch { /* "error on deocde currency */ }
        // couponCode
        do { self.couponCode = try values.decode(String.self, forKey: .couponCode) } catch { /* "error on deocde couponCode */ }
        // paymentMethod
        do { self.paymentMethod = try values.decode(String.self, forKey: .paymentMethod) } catch { /* "error on deocde paymentMethod */ }
        // shippingMethod
        do { self.shippingMethod = try values.decode(String.self, forKey: .shippingMethod) } catch { /* "error on deocde shippingMethod */ }
        // itemCount
        do { self.itemCount = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .itemCount)) } catch { /* "error on deocde itemCount */ }

        do {
            try super.init(from: decoder)
        }
        self.type = .TRANSACTION
    }

    private enum CodingKeys: String, CodingKey {
        case affiliation = "tid"
        case transactionId = "ta"
        case revenue = "tr"
        case shipping = "ts"
        case tax = "tt"
        case currency = "tc"
        case couponCode = "tcc"
        case paymentMethod = "pm"
        case shippingMethod = "sm"
        case itemCount = "icn"
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")

        // Set transactionId
        //  if self.transactionId != nil {
        customParams.updateValue(self.transactionId, forKey: "tid")
        // }
        // Set affiliation
        //  if self.affiliation != nil {
        customParams.updateValue(self.affiliation, forKey: "ta")
        // }
        // Set price
        if self.revenue != nil {
            customParams.updateValue(self.revenue ?? 0, forKey: "tr")
        }
        // Set shipping
        if self.shipping != nil {
            customParams.updateValue(self.shipping ?? 0, forKey: "ts")
        }
        // Set Tax
        if self.tax != nil {
            customParams.updateValue(self.tax ?? 0, forKey: "tt")
        }
        // Set currency
        if self.currency != nil {
            customParams.updateValue(self.currency ?? "", forKey: "tc")
        }
        // Set couponCode
        if self.couponCode != nil {
            customParams.updateValue(self.couponCode ?? "", forKey: "tcc")
        }
        // Set paymentMethod
        if self.paymentMethod != nil {
            customParams.updateValue(self.paymentMethod ?? "", forKey: "pm")
        }
        // Set ShippingMethod
        if self.shippingMethod != nil {
            customParams.updateValue(self.shippingMethod ?? "", forKey: "sm")
        }
        // Set itemCount
        if self.itemCount != nil {
            customParams.updateValue(self.itemCount ?? 0, forKey: "icn")
        }

        customParams.merge(self.communBodyTrack) { _, new in new }

        return customParams
    }
}

/**
 Represent item with a transaction. It must be sent after the corresponding transaction.
 */

@objcMembers public class FSItem: FSTracking {
    /// Transaction unique identifier
    private(set) var transactionId: String

    /// Product name
    private(set) var name: String

    /// Specifies the item price
    public var price: NSNumber?

    /// Specifies the item quantity
    public var quantity: NSNumber?

    /// Specifies the item code or SKU
    private(set) var code: String!

    /// Specifies the item category
    public var category: String?

    /**
     Init Item object

     @param transactionId :String

     @param name :String

     @return instance object
     */
    public init(transactionId: String, name: String, code: String) {
        self.transactionId = transactionId
        self.name = name
        super.init()
        self.type = .ITEM
        self.price = 0
        self.quantity = 0
        self.code = code
        self.category = nil
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // name
        do { self.name = try values.decode(String.self, forKey: .name) } catch { self.name = "" }
        // transactionId
        do { self.transactionId = try values.decode(String.self, forKey: .transactionId) } catch { self.transactionId = "" }
        // price
        do { self.price = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .price)) } catch { /* error on deocde price*/ }
        // quantity
        do { self.quantity = try NSNumber(floatLiteral: values.decode(Double.self, forKey: .quantity)) } catch { /* error on decode quantity*/ }
        // code
        do { self.code = try values.decode(String.self, forKey: .code) } catch { /* error on decode code*/ }
        // category
        do { self.category = try values.decode(String.self, forKey: .category) } catch { /* error on decode categoty*/ }
        do { try super.init(from: decoder) }
        self.type = .ITEM
    }

    private enum CodingKeys: String, CodingKey {
        case name = "tid"
        case transactionId = "in"
        case price = "ip"
        case quantity = "iq"
        case code = "ic"
        case category = "iv"
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")

        // Set transactionId
        // if self.transactionId != nil {
        customParams.updateValue(self.transactionId, forKey: "tid")
        // }
        // Set name
        /// if self.name != nil {
        customParams.updateValue(self.name, forKey: "in")
        // }
        // Set price
        if self.price != nil {
            customParams.updateValue(self.price ?? 0, forKey: "ip")
        }
        // Set quantity
        if self.quantity != nil {
            customParams.updateValue(self.quantity ?? 0, forKey: "iq")
        }
        // Set code
        if self.code != nil {
            customParams.updateValue(self.code ?? "", forKey: "ic")
        }
        // Set category
        if self.category != nil {
            customParams.updateValue(self.category ?? "", forKey: "iv")
        }

        customParams.merge(self.communBodyTrack) { _, new in new }

        return customParams
    }
}

/**

 Represents an event
 */
@objcMembers public class FSEvent: FSTracking {
    /// category of the event (Action_Tracking or User_Engagement).
    private(set) var category: FSCategoryEvent = .Action_Tracking

    /// name of the event.
    private(set) var action: String?

    /// description of the event.
    public var label: String?

    /// value of the event, must be non-negative. (An unsigned integer value type)
    public var eventValue: UInt?

    /**
     Init Event object

     @param eventCategory :FSCategoryEvent

     @param eventAction :String

     @return instance object
     */
    public init(eventCategory: FSCategoryEvent, eventAction: String) {
        super.init() /// Set dans la base les element vitales

        self.type = .EVENT

        self.category = eventCategory

        self.action = eventAction

        self.label = nil

        self.eventValue = nil
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { try super.init(from: decoder) }
        // category
        do { let catString = try values.decode(String.self, forKey: .category)
            if catString == FSCategoryEvent.Action_Tracking.categoryString {
                self.category = .Action_Tracking
            } else {
                self.category = .User_Engagement
            }
        } catch { self.category = .Action_Tracking }

        // action
        do { self.action = try values.decode(String.self, forKey: .action) } catch { /* error on decode action*/ }
        // label
        do { self.label = try values.decode(String.self, forKey: .label) } catch { /* error on decode label*/ }
        // event value
        do { self.eventValue = try values.decode(UInt.self, forKey: .eventValue) } catch { /* error on decode eventValue*/ }
        // Set event category
        self.category = .Action_Tracking
        // Set type
        self.type = .EVENT
    }

    private enum CodingKeys: String, CodingKey {
        case category = "ec"
        case action = "ea"
        case label = "el"
        case eventValue = "ev"
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        // Set category
        customParams.updateValue(self.category.categoryString, forKey: "ec")
        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")
        // Set Action
        customParams.updateValue(self.action ?? "", forKey: "ea")
        // Set Label
        if self.label != nil {
            customParams.updateValue(self.label ?? "", forKey: "el")
        }
        // Set Value
        if self.eventValue != nil {
            customParams.updateValue(self.eventValue ?? 0, forKey: "ev")
        }
        // Merge the commun params
        customParams.merge(self.communBodyTrack) { _, new in new }

        return customParams
    }

    @available(swift, obsoleted: 1.0)
    public func setEventValue(_ newValue: UInt) {
        self.eventValue = newValue
    }
}

internal class FSConsent: FSEvent {
    override init(eventCategory: FSCategoryEvent, eventAction: String) {
        super.init(eventCategory: eventCategory, eventAction: eventAction)
        self.type = .CONSENT
    }

    override public var fileName: String! {
        let formatDate = DateFormatter()
        formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
        return String(format: "consent_%@.json", formatDate.string(from: Date()))
    }

    public required init(from decoder: Decoder) throws {
        do {
            try super.init(from: decoder)
        }
    }
}
