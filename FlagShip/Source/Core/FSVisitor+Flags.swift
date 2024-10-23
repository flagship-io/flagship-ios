//
//  FSVisitor+Flags.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/04/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

public extension FSVisitor {
    /// Get FSFlag object
    /// - Parameter key: key represent key modification
    /// - Returns: FSFLag object
    func getFlag(key: String) -> FSFlag {
        // We dispaly a warning if the flag's status is not fetched
        if self.fetchStatus != .FETCHED {
            FlagshipLogManager.Log(level: .ALL, tag: .FLAG, messageToDisplay: FSLogMessage.MESSAGE(self.requiredFetchReason.warningMessage(key, self.visitorId)))
        }
        return FSFlag(key, self.strategy)
    }

    /// Getting FSFlagCollection
    /// - Returns: an instance of FSFlagCollection with flags
    func getFlags() -> FSFlagCollection {
        var ret: [String: FSFlag] = [:]
        self.currentFlags.forEach { (key: String, _: FSModification) in

            ret.updateValue(FSFlag(key, self.strategy), forKey: key)
        }
        return FSFlagCollection(flags: ret)
    }
}

// We keep FlagMap instead using FSFlagV4 wich is also possible
public class FSFlagCollection: Sequence {
    private var flags: [String: FSFlag] = [:]

    // Init from the visitor
    init(flags: [String: FSFlag]) {
        self.flags = flags
    }

    public func makeIterator() -> DictionaryIterator<String, FSFlag> {
        return self.flags.makeIterator()
    }

    public subscript(key: String) -> FSFlag {
        get {
            return self.flags[key] ?? FSFlag(key, nil)
        }
        set(newValue) {
            self.flags[key] = newValue
        }
    }

    // Filtering on the flagvariant object
    func filter(_ isIncluded: (String, FSFlag) throws -> Bool) rethrows -> FSFlagCollection {
        let filteredFlags = try flags.filter(isIncluded)
        return FSFlagCollection(flags: filteredFlags)
    }

    public func keys() -> Dictionary<String, FSFlag>.Keys {
        return self.flags.keys
    }

    public func metadatas() -> [FSFlagMetadata] {
        self.flags.map { (_: String, value: FSFlag) in
            value.metadata()
        }
    }

    public func toJson() -> String {
        var arrayOfjson: [[String: Any]] = []
        self.flags.forEach { (_: String, value: FSFlag) in
            var hexString = ""
            if let modif = value.strategy?.getStrategy().getFlagModification(value.key) {
                do {
                    let hexDico: [String: Any] = ["v": modif.value]
                    if let dicoData = try? JSONSerialization.data(withJSONObject: hexDico) {
                        hexString = dicoData.hexEncodedString()
                        arrayOfjson.append(FSExtraMetadata(modif, value.key, hex: hexString).toJson())
                    }
                }
            }
        }
        if !arrayOfjson.isEmpty {
            if let globalDico = try? JSONSerialization.data(withJSONObject: arrayOfjson) {
                return String(data: globalDico, encoding: .utf8) ?? ""
            }
        }
        return ""
    }

    public func exposeAll() {
        self.flags.forEach { (_: String, value: FSFlag) in
            value.visitorExposed()
        }
    }

    public var count: Int {
        return self.flags.count
    }

    public var isEmpty: Bool {
        return self.flags.isEmpty
    }
}

class FSExtraMetadata: FSFlagMetadata {
    var key: String = ""
    var hex: String = ""
    init(_ modification: FSModification?, _ key: String, hex: String) {
        self.key = key
        self.hex = hex
        super.init(modification)
    }

    override func toJson() -> [String: Any] {
        var ret = super.toJson()
        // Add key
        ret.merge(["key": self.key]) { _, new in new }
        // Add hex value
        ret.merge(["hex": self.hex]) { _, new in new }
        return ret
    }
}
