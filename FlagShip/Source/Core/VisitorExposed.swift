//
//  VisitorExposed.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

public class VisitorExposed: NSObject {
    public private(set) var id: String
    public private(set) var anonymousId: String?
    public private(set) var context: [String: Any] = [:]

    init(id: String, anonymousId: String? = nil, context: [String: Any]) {
        self.id = id
        self.anonymousId = anonymousId
        self.context = context
    }

    public func toJson() -> [String: Any] {
        var result: [String: Any] = [
            "id": id,
            "context": context
        ]

        if let aAnonymousId = anonymousId {
            result.updateValue(aAnonymousId, forKey: "anonymousId")
        }
        return result
    }
}
