//
//  FSVisitor+Flags.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/04/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

/// Solution 1 -
extension FSVisitor: FlagVisitorDelegate {
    // Delegate for the visitor
    func exposeAll(_ Keys: [String]?) {
        Keys?.forEach { keyFlag in

            self.strategy?.getStrategy().activate(keyFlag)
        }
    }

    public func getFlag<T>(_ key: String, _ defaultValue: T) -> FSFlag {
        return self.getFlag(key: key, defaultValue: defaultValue)
    }

    public func allFlags() -> [String: Any] {
        self.currentFlags.mapValues { modif in
            modif.value
        }
    }

    /// Solution 2 -
    // Key
    // Payload <===> Metadat
    // Status of flag at the screeshot

    public func getFlagList() -> [FlagVariant] {
        self.currentFlags.map { (key: String, modif: FSModification) in
            FlagVariant(key: key, value: modif.value, metadata: FSFlagMetadata(modif))
        }
    }

    /// Solution 3 -
    ///
    public func getAllFlag() -> FSMagikFlag {
        let listofKeyself = currentFlags.map { (key: String, _: FSModification) in
            key
        }
        return FSMagikFlag(aKey: listofKeyself, self)
    }

    // Get flagMap
    public func getFlagMap() -> FlagMap {
        var ret: [String: FSFlagV4] = [:]
        self.currentFlags.forEach { (key: String, _: FSModification) in

            ret.updateValue(FSFlagV4(key, self.strategy), forKey: key)
        }
        return FlagMap(flags: ret)
    }
}

// Solution 3
public class FSMagikFlag {
    private var delegate: FlagVisitorDelegate

    public var keys: [String] /// List keys

    init(aKey: [String], _ aDelegate: FlagVisitorDelegate) {
        self.delegate = aDelegate
        self.keys = aKey
    }

    public func getFlag<T>(_ key: String, _ defaultValue: T) -> FSFlag {
        return self.delegate.getFlag(key, defaultValue)
    }

    public func activateAll(pKeys: [String]? = nil) {
        if pKeys == nil {
            self.delegate.exposeAll(self.keys)
        } else {
            // Check the existing keys before of filter
            self.delegate.exposeAll(pKeys)
        }
    }
}

//protocol FlagVisitorDelegate {
//    // Get flag
//    func getFlag<T>(_ key: String, _ defaultValue: T) -> FSFlag
//
//    // Activate all
//    func exposeAll(_ Keys: [String]?)
//}

// Flag without operations
// without a default value to operate -
public class FlagVariant {
    // Flag key
    public let key: String
    // Value for Flag
    public let value: Any?
    // metadata
    public let metadata: FSFlagMetadata

    init(key: String, value: Any?, metadata: FSFlagMetadata) {
        self.key = key
        self.metadata = metadata
        self.value = value
    }
}



// We keep FlagMap instead using FSFlagV4 wich is also possible
public class FlagMap: Sequence {
    private var flags: [String: FSFlagV4] = [:]

    // private var delegate: FlagVisitorDelegate

    // Init from the visitor
    init(flags: [String: FSFlagV4]) {
        self.flags = flags
    }

    public func makeIterator() -> DictionaryIterator<String, FSFlagV4> { /// Iterate on the Flagvariant object
        return self.flags.makeIterator()
    }

    public subscript(key: String) -> FSFlagV4? {
        get {
            return self.flags[key]
        }
        set(newValue) {
            self.flags[key] = newValue
        }
    }

    // Filtering on the flagvariant object
    func filter(_ isIncluded: (String, FSFlagV4) throws -> Bool) rethrows -> FlagMap {
        let filteredFlags = try flags.filter(isIncluded)
        return FlagMap(flags: filteredFlags)
    }

    public func exposeAll() {
        self.flags.forEach { (_: String, value: FSFlagV4) in
            value.visitorExposed()
        }
    }
}
