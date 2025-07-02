//
//  VisitorExposed.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

@objc public class FSVisitorExposed: NSObject {
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

    // Init with dico

    init(dico: [String: Any]) {
        self.id = dico["id"] as? String ?? ""
        self.anonymousId = dico["anonymousId"] as? String
        self.context = dico["context"] as? [String: Any] ?? [:]
    }

    /// Dictionary that represent the Visitor Exposed
    /// - Return: [String: Any]
    @objc public func toDictionary() -> [String: Any] {
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
    @objc public func toJson() -> NSString? {
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

/// Used by TRManager to forward infos through closure

class FSExposedInfo {
    let exposedFlag: FSExposedFlag
    let visitorExposed: FSVisitorExposed

    init(exposedFlag: FSExposedFlag, visitorExposed: FSVisitorExposed) {
        self.exposedFlag = exposedFlag
        self.visitorExposed = visitorExposed
    }
}
