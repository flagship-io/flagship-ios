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

//
//       Batch for Activate
//
/////////////////////////////////////
///

class Activate: FSTrackingProtocol {
    func isValid() -> Bool {
        return true
    }

    var queueTimeBis: NSNumber?

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

        let shared = Flagship.sharedInstance
        if let aEnvId = shared.envId {
            self.envId = aEnvId
        }
    }

    init(_ visitorId: String, _ anonymousId: String?, modification: FSModification) {
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
        customParams.updateValue(self.envId ?? "}", forKey: "cid")
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

        return customParams
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

        for item in self.listActivate {
            var elemToAdd = item.bodyTrack
            elemToAdd.removeValue(forKey: "cid")
            ret.append(elemToAdd)
        }
        return ["cid": self.envId, "batch": ret]
    }
}
