//
//  FSBatch.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

class FSBatch: FSTracking {
    var items: [FSTrackingProtocol] = []

    override public init() {
        super.init()
        self.type = .BATCH
    }

    init(_ listOfHit: [FSTrackingProtocol]) {
        super.init()
        // Set the envId
        self.envId = listOfHit.first?.envId
        // Set the type
        self.type = .BATCH
        // Set the Data Source
        self.dataSource = "APP"
        // Insert the hits
        self.items.append(contentsOf: listOfHit)
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")
        // Set Client Id
        customParams.updateValue(self.envId ?? "", forKey: "cid") //// Rename it
        // Set Data source
        customParams.updateValue(self.dataSource, forKey: "ds")
        var listsForHKey: [[String: Any]] = []

        // Fill the list of hit thant contain a batch
        for item: FSTrackingProtocol in self.items {
            listsForHKey.append(item.bodyTrack)
        }
        customParams.updateValue(listsForHKey, forKey: "h")
        return customParams
    }
}


////////////////////
// Activate class //
////////////////////

class Activate: FSTrackingProtocol, Codable {
    var createdAt: TimeInterval = 0

    func isValid() -> Bool {
        return true
    }
    
    var id: String = ""

    var anonymousId: String?

    var visitorId: String?

    var type: FSTypeTrack

    var fileName: String!

    var envId: String?

    // VariationId
    var variationId: String?
    // Variation GroupId
    var variationGroupeId: String?

//    func getCst() -> NSNumber? {
//        return 0
//    }

    init(_ visitorId: String, _ anonymousId: String?, variationId: String, variationGroupeId: String) {
        // Created date
        self.createdAt = Date().timeIntervalSince1970
        self.type = .ACTIVATE
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.variationId = variationId
        self.variationGroupeId = variationGroupeId

        let shared = Flagship.sharedInstance
        if let aEnvId = shared.envId {
            self.envId = aEnvId
        }
    }

    init(_ visitorId: String, _ anonymousId: String?, modification: FSModification) {
        self.createdAt = Date().timeIntervalSince1970
        self.envId = Flagship.sharedInstance.envId
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.variationId = modification.variationId
        self.variationGroupeId = modification.variationGroupId
        self.type = .ACTIVATE
    }

    public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set client Id
        customParams.updateValue(self.envId ?? "", forKey: "cid")
        // VariationId
        customParams.updateValue(self.variationId ?? "", forKey: "vaid")
        // Variation GroupId
        customParams.updateValue(self.variationGroupeId ?? "", forKey: "caid")
        // Set visitor id
        customParams.updateValue(self.visitorId ?? "", forKey: "vid")
        // Set anonymous Id if is defined
        if let aId = anonymousId {
            customParams.updateValue(aId, forKey: "aid")
        }
        /// Add qt entries
        /// Time difference between when the hit was created and when it was sent
        let qt = Date().timeIntervalSince1970 - self.createdAt
        customParams.updateValue(qt.rounded(), forKey: "qt")
        return customParams
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // visitorId
        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        // anonymousId
        do { self.anonymousId = try values.decode(String.self, forKey: .anonymousId) } catch { /* error on decode aid */ }
        // envid
        do { self.envId = try values.decode(String.self, forKey: .envId) } catch { /* error on deocde envId*/ }
        // variationId
        do { self.variationId = try values.decode(String.self, forKey: .variationId) } catch { /* error on decode variationId*/ }
        // variationGroupeId
        do { self.variationGroupeId = try values.decode(String.self, forKey: .variationGroupeId) } catch { /* error on decode variationGroupeId*/ }
        self.type = .ACTIVATE

        do {
            self.createdAt = try values.decode(Double.self, forKey: .createdAt) // TODO: , Make it optional

        } catch {
            self.createdAt = 0
        }
    }

    private enum CodingKeys: String, CodingKey {
        case visitorId = "vid"
        case anonymousId = "aid"
        case envId = "cid"
        case variationId = "vaid"
        case variationGroupeId = "caid"
        // Created time
        case createdAt = "qt" // See later the optional
    }

    internal func description() -> String {
        do {
            let stringDescription = try JSONSerialization.data(withJSONObject: self.bodyTrack as Any, options: .prettyPrinted)
            return "\(stringDescription.prettyPrintedJSONString ?? "")"

        } catch {
            return ""
        }
    }
}

class ActivateBatch {
    var listActivate: [FSTrackingProtocol] = []
    var envId: String = ""
    var currentActivate: FSTrackingProtocol?

    init(pCurrentActivate: FSTrackingProtocol?) {
        self.currentActivate = pCurrentActivate
        self.envId = Flagship.sharedInstance.envId ?? ""
    }

    func addElement(_ newElement: FSTrackingProtocol) {
        self.listActivate.append(newElement)
    }

    func addListOfElement(_ list: [FSTrackingProtocol]) {
        self.listActivate.append(contentsOf: list)
    }

    public var bodyTrack: [String: Any] {
        var ret: [[String: Any]] = []

        if let aCurrentActivate = self.currentActivate {
            ret.append(aCurrentActivate.bodyTrack)
        }

        for item in self.listActivate {
            var elemToAdd = item.bodyTrack
            elemToAdd.removeValue(forKey: "cid")
            ret.append(elemToAdd)
        }
        return ["cid": self.envId, "batch": ret]
    }
}
