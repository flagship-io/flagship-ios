//
//  ExposedFlag.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

protocol IFlag {
    // Key for flag
    var key: String { get set }

    // Default value
    var defaultValue: Any? { get set }

    // Get metadata
    var metadata: FSFlagMetadata { get set }

    // Already activated campaign
    var alreadyActivatedCampaign: Bool? { get }
}

@objc public class FSExposedFlag: NSObject, IFlag {
    // Key for flag
    public internal(set) var key: String

    // Default value
    public internal(set) var defaultValue: Any?

    // Get metadata
    public internal(set) var metadata: FSFlagMetadata

    // Value for flag
    public private(set) var value: Any?

    // Already activated campaign
    public var alreadyActivatedCampaign: Bool? = true

    init(key: String, defaultValue: Any? = nil, metadata: FSFlagMetadata, value: Any?, alreadyActivatedCampaign: Bool = false) {
        self.key = key
        self.defaultValue = defaultValue
        self.metadata = metadata
        self.value = value
        self.alreadyActivatedCampaign = alreadyActivatedCampaign
    }

    init(exposedInfo: [String: Any]) {
        self.key = exposedInfo["key"] as? String ?? ""
        self.value = exposedInfo["value"]
        self.defaultValue = exposedInfo["defaultValue"]
        self.metadata = FSFlagMetadata(metadataDico: exposedInfo["metadata"] as? [String: Any] ?? [:])
        self.alreadyActivatedCampaign = exposedInfo["alreadyActivatedCampaign"] as? Bool ?? false // TODO: Review & test later
    }

    ///   Dictionary that represent the Exposed Flag
    /// - return: [String: Any]
    @objc public func toDictionary() -> [String: Any] {
        var result: [String: Any] = [
            "key": key,
            "metadata": metadata.toJson()
        ]

        if let aDefaultValue = defaultValue {
            result.updateValue(aDefaultValue, forKey: "defaultValue")
        }

        if let aValue = value {
            result.updateValue(aValue, forKey: "value")
        }

        if let aAlreadyActivatedCampaign = alreadyActivatedCampaign {
            result.updateValue(aAlreadyActivatedCampaign, forKey: "alreadyActivatedCampaign")
        }

        return result
    }

    ///   String that represent a json for the Exposed Flag
    /// - Return: String?
    @objc public func toJson() -> NSString {
        var result: [String: Any] = [
            "key": key,
            "metadata": metadata.toJson()
        ]

        if let aDefaultValue = defaultValue {
            result.updateValue(aDefaultValue, forKey: "defaultValue")
        }

        if let aValue = value {
            result.updateValue(aValue, forKey: "value")
        }

        if let aAlreadyActivated = alreadyActivatedCampaign {
            result.updateValue(aAlreadyActivated, forKey: "alreadyActivatedCampaign")
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
            return ""
        }
        return jsonData.prettyPrintedJSONString ?? ""
    }
}
