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

// {
//    "t": "BATCH",
//    "cid": "bkk4s7gcmjcg07fke9dg",
//    "ds": "APP",

//    "h": [
//        {
//            "vid": "visitor1",
//            "t": "PAGEVIEW",
//            "dl": "https://myurl.com",
//            "qt": 9210
//        },
//        {
//            "vid": "visitor1",
//            "ev": 12,
//            "t": "EVENT",
//            "el": "label",
//            "ea": "action",
//            "ec": "Action Tracking",
//            "qt": 4178
//        }
//    ]
// }
