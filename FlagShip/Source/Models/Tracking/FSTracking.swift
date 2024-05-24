//
//  FSTracking.swift
//  Flagship
//
//  Created by Adel on 11/10/2021.
//

import Foundation

@objc public enum FSTypeTrack: NSInteger {
    case SCREEN = 0
    case PAGE
    case TRANSACTION
    case ITEM
    case EVENT
    case CONSENT
    case BATCH
    case ACTIVATE
    case SEGMENT
    case TROUBLESHOOTING
    case USAGE
    case None

    public var typeString: String {
        switch self {
        case .SCREEN:
            return "SCREENVIEW"
        case .PAGE:
            return "PAGEVIEW"
        case .TRANSACTION:
            return "TRANSACTION"
        case .ITEM:
            return "ITEM"
        case .EVENT, .CONSENT:
            return "EVENT"
        case .BATCH:
            return "BATCH"
        case .ACTIVATE:
            return "ACTIVATE"
        case .SEGMENT:
            return "SEGMENT"
        case .TROUBLESHOOTING:
            return "TROUBLESHOOTING"
        case .USAGE:
            return "USAGE"
        case .None:
            return "None"
        }
    }
}

/// Enumeration that represent Events type
@objc public enum FSCategoryEvent: NSInteger {
    /// Action tracking
    case Action_Tracking = 1

    /// User engagement
    case User_Engagement = 2

    /// :nodoc:
    public var categoryString: String {
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
    var id: String { get set }

    var anonymousId: String? { get set }

    var visitorId: String? { get set }

    var type: FSTypeTrack { get }

    var bodyTrack: [String: Any] { get }

    /// Required
    var envId: String? { get }

    /// Queue Time
    //  var queueTimeBis: NSNumber? { get }

    /// Get cst
    // func getCst() -> NSNumber?

    func isValid() -> Bool

    // Created time
    var createdAt: TimeInterval { get set }
}

@objcMembers public class FSTracking: NSObject, FSTrackingProtocol, Codable {
    public var createdAt: TimeInterval

    public var visitorId: String?

    public var id: String

    // Anonymous ID
    public var anonymousId: String?

    public var fileName: String! {
        let formatDate = DateFormatter()
        formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
        return String(format: "%@.json", formatDate.string(from: Date()))
    }

    // Here will add all commun args
    public var type: FSTypeTrack = .None

    /// Required
    public var envId: String?
    var fsUserId: String?
    var dataSource: String = "APP"

    /// User Ip
    public var userIp: String?
    /// Screen Resolution
    public var screenResolution: String?
    /// Screen Color Depth
    public var screenColorDepth: String?
    /// User Language
    public var userLanguage: String?
    /// Current Session Time Stamp
    public var currentSessionTimeStamp: TimeInterval?
    /// Session Number
    public var sessionNumber: NSNumber?

    // Session Event Number
    public var sessionEventNumber: NSNumber?

    override init() {
        self.id = ""
        self.envId = Flagship.sharedInstance.envId
        // Set TimeInterval
        self.currentSessionTimeStamp = 1674575397 // Date().timeIntervalSince1970
        // Created date
        self.createdAt = Date().timeIntervalSince1970
    }

    public var bodyTrack: [String: Any] {
        return [:]
    }

    public var communBodyTrack: [String: Any] {
        var communParams = [String: Any]()

        // Set Client Id
        communParams.updateValue(self.envId ?? "", forKey: "cid") //// Rename it
        // Set Data source
        communParams.updateValue(self.dataSource, forKey: "ds")

        // Set User ip
        if self.userIp != nil {
            communParams.updateValue(self.userIp ?? "", forKey: "uip")
        }
        // Set Resolution Screen
        if self.screenResolution != nil {
            communParams.updateValue(self.screenResolution ?? "", forKey: "sr")
        }
        // Set  Screen Color Depth
        if self.screenColorDepth != nil {
            communParams.updateValue(self.screenColorDepth ?? "", forKey: "sd")
        }
        // User Language
        if self.userLanguage != nil {
            communParams.updateValue(self.userLanguage ?? "", forKey: "ul")
        }

        // Session Number
        if self.sessionNumber != nil {
            communParams.updateValue(self.sessionNumber ?? 0, forKey: "sn")
        }
        // Merge the visitorId and AnonymousId
        communParams.merge(self.createTupleId()) { _, new in new }

        /// Add qt entries
        /// Time difference between when the hit was created and when it was sent
         let qt = Date().timeIntervalSince1970 - self.createdAt      
         communParams.updateValue(qt.rounded(), forKey: "qt")


        return communParams
    }

    public func isValid() -> Bool {
        if let aVisitorId = self.visitorId, let aClientId = self.envId {
            return !aVisitorId.isEmpty && !aClientId.isEmpty && self.type != .None
        }

        return false
    }

    func createTupleId() -> [String: String] {
        var tupleId = [String: String]()

        if self.anonymousId != nil /* && self.visitorId != nil */ {
            // envoyer: cuid = visitorId, et vid=anonymousId
            tupleId.updateValue(self.visitorId ?? "", forKey: "cuid") //// rename it
            tupleId.updateValue(self.anonymousId ?? "", forKey: "vid") //// rename it
        } else /* if self.visitorId != nil*/ {
            // Si visitorid défini mais pas anonymousId, cuid pas envoyé, vid = visitorId
            tupleId.updateValue(self.visitorId ?? "", forKey: "vid") //// rename it
        }
        return tupleId
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.id = try values.decode(String.self, forKey: .id) } catch { self.id = "" }
        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        do { self.envId = try values.decode(String.self, forKey: .envId) } catch { self.envId = "" }
        do {
            self.createdAt = try values.decode(Double.self, forKey: .createdAt)

        } catch {
            self.createdAt = 0
        }
    }

    public func encode(to encoder: Encoder) throws {}

    private enum CodingKeys: String, CodingKey {
        // VisitorId
        case visitorId = "vid"
        // Anonymous Id
        case anonymousId = "cuid"
        case id
        // Client Id
        case envId = "cid"
        // Datasource
        case dataSource = "ds"
        /// User Ip
        case userIp = "uip"
        /// Screen Resolution
        case screenResolution = "sr"
        /// User Language
        case userLanguage = "ul"
        /// Session Number
        case sessionNumber = "sn"
        // Created time
        case createdAt = "qt" // See later the optional
    }
}
