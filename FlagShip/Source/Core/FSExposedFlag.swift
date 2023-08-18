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
}

@objc public class FSExposedFlag:NSObject, IFlag {
    // Key for flag
    public internal(set) var key: String

    // Default value
    public internal(set) var defaultValue: Any?

    // Get metadata
    public internal(set) var metadata: FSFlagMetadata

    // Value for flag
    public private(set) var value: Any?

    internal init(key: String, defaultValue: Any? = nil, metadata: FSFlagMetadata, value: Any?) {
        self.key = key
        self.defaultValue = defaultValue
        self.metadata = metadata
        self.value = value
    }

    /// Dictionary that represent the Exposed Flag
    /// - Return: [String: Any]
    public func toDictionary() -> [String: Any] {
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

        return result
    }

    /// String that represent a json for the Exposed Flag
    /// - Return: NSString ?
    public func toJson() -> NSString? {
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

        guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
            return nil
        }
        return jsonData.prettyPrintedJSONString
    }
}
