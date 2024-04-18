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
        var ret: [String: FlagVariant] = [:]
        self.currentFlags.forEach { (key: String, modif: FSModification) in
            ret.updateValue(FlagVariant(key: key, value: modif.value, metadata: FSFlagMetadata(modif)), forKey: key)
        }
        return FlagMap(flagVariants: ret, pDelegate: self)
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

protocol FlagVisitorDelegate {
    // Get flag
    func getFlag<T>(_ key: String, _ defaultValue: T) -> FSFlag

    // Activate all
    func exposeAll(_ Keys: [String]?)
}

// Flag without operations
// without a default value to operate -
public class FlagVariant {
    // Flag key
    public let key: String
    // Value for Flag
    public let value: Any?
    // metadata
    public let metadata: FSFlagMetadata

    init(key: String, metadata: FSFlagMetadata) {
        self.key = key
        self.value = value
        self.metadata = metadata
    }
    
    
    
   
}




public class FlagMap: Sequence {
    private var flags: [String: FSFlag] = [:]

    public private(set) var flagVariants: [String: FlagVariant] = [:]

    private var delegate: FlagVisitorDelegate

    // Init from the visitor
    init(flagVariants: [String: FlagVariant], pDelegate: FlagVisitorDelegate) {
        self.flagVariants = flagVariants
        self.delegate = pDelegate
    }

    public func makeIterator() -> DictionaryIterator<String, FlagVariant> { /// Iterate on the Flagvariant object
        return self.flagVariants.makeIterator()
    }

    public subscript<T>(key: String, defaultValue: T) -> FSFlag? {
        get {
            return self.delegate.getFlag(key, defaultValue) // Return the flag from the delegate
            // return self.flags[key]
        }
        set(newValue) {
            self.flags[key] = newValue
        }
    }

 

    // Filtering on the flagvariant object
    func filter(_ isIncluded: (String, FlagVariant) throws -> Bool) rethrows -> FlagMap {
        let filteredFlags = try flagVariants.filter(isIncluded)
        return FlagMap(flagVariants: filteredFlags, pDelegate: self.delegate)
    }

    public func exposeAll() {
        self.delegate.exposeAll(self.flagVariants.map { (key: String, _: FlagVariant) in
            key
        })
    }
}
