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
        for item: FSTrackingProtocol in self.items {
            listsForHKey.append(item.bodyTrack)
        }
        customParams.updateValue(listsForHKey, forKey: "h")
        return customParams
    }
}

//
//       Batch for Activate
//
/////////////////////////////////////
///

class Activate: FSTrackingProtocol {
    var queueTimeBis: NSNumber?

    var id: String?

    var anonymousId: String?

    var visitorId: String?

    var type: FSTypeTrack

    var fileName: String!

    var envId: String?

    // VariationId
    var variationId: String?
    // Variation GroupId
    var variationGroupeId: String?

    func getCst() -> NSNumber? {
        return 0
    }

    init(_ visitorId: String, _ anonymousId: String?, variationId: String, variationGroupeId: String) {
        self.queueTimeBis = NSNumber(value: Date().timeIntervalSince1970)
        self.type = .ACTIVATE
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.variationId = variationId
        self.variationGroupeId = variationGroupeId
    }

    public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")
        // EnvId
        customParams.updateValue(self.envId ?? "", forKey: "cid")
        // VariationId
        customParams.updateValue(self.variationId ?? "", forKey: "vaid")
        // Variation GroupId
        customParams.updateValue(self.variationGroupeId ?? "", forKey: "caid")

        //  customParams.updateValue(self.queueTimeBis , forKey: "qt") // Revoie later

        return customParams
    }
}

class ActivateBatch {
    var listActivate: [FSTrackingProtocol]

    var envId: String = ""

    init(listActivate: [FSTrackingProtocol]) {
        self.listActivate = listActivate
        self.envId = listActivate.first?.envId ?? ""
    }

    public var bodyTrack: [String: Any] {
        var ret: [[String: Any]] = []

        for item in self.listActivate {
            var elemToAdd = item.bodyTrack
            elemToAdd.removeValue(forKey: "cid")
            ret.append(elemToAdd)
        }
        return ["cid": self.envId, "batch": ret]
    }
}
