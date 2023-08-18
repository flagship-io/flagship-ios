//
//  VisitorExposed.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

@objc public class FSVisitorExposed :NSObject{
    // visitorId
    public private(set) var id: String
    // Anonymous Id
    public private(set) var anonymousId: String?
    // Context for the visitor
    public private(set) var context: [String: Any] = [:]

    // Init
    init(id: String, anonymousId: String? = nil, context: [String: Any]) {
        self.id = id
        self.anonymousId = anonymousId
        self.context = context
    }

    /// Dictionary that represent the Visitor Exposed
    /// - Return: [String: Any]
    public func toDictionary() -> [String: Any] {
        var result: [String: Any] = [
            "id": id,
            "context": context
        ]

        if let aAnonymousId = anonymousId {
            result.updateValue(aAnonymousId, forKey: "anonymousId")
        }
        return result
    }

    /// String that represent a json for the Visitor Exposed
    /// - Return: NSString ?
    public func toJson() -> NSString? {
        var result: [String: Any] = [
            "id": id,
            "context": context
        ]

        if let aAnonymousId = anonymousId {
            result.updateValue(aAnonymousId, forKey: "anonymousId")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
            return nil
        }
        return jsonData.prettyPrintedJSONString
    }
}
