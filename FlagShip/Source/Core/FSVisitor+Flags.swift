//
//  FSVisitor+Flags.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/04/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

/// Solution 1 -
extension FSVisitor {
    // Delegate for the visitor
    func exposeAll(_ Keys: [String]?) {
        Keys?.forEach { keyFlag in

            self.strategy?.getStrategy().activate(keyFlag)
        }
    }

//    public func getFlag<T>(_ key: String, _ defaultValue: T) -> FSFlag {
//        return self.getFlag(key: key, defaultValue: defaultValue)
//    }

    public func allFlags() -> [String: Any] {
        self.currentFlags.mapValues { modif in
            modif.value
        }
    }



    // Get flagMap
    public func getFlagMap() -> FlagMap {
        var ret: [String: FSFlag] = [:]
        self.currentFlags.forEach { (key: String, _: FSModification) in

            ret.updateValue(FSFlag(key, self.strategy), forKey: key)
        }
        return FlagMap(flags: ret)
    }
}

 
// We keep FlagMap instead using FSFlagV4 wich is also possible
public class FlagMap: Sequence {
    private var flags: [String: FSFlag] = [:]

    // Init from the visitor
    init(flags: [String: FSFlag]) {
        self.flags = flags
    }

    public func makeIterator() -> DictionaryIterator<String, FSFlag> { /// Iterate on the Flagvariant object
        return self.flags.makeIterator()
    }

    public subscript(key: String) -> FSFlag? {
        get {
            return self.flags[key]
        }
        set(newValue) {
            self.flags[key] = newValue
        }
    }

    // Filtering on the flagvariant object
    func filter(_ isIncluded: (String, FSFlag) throws -> Bool) rethrows -> FlagMap {
        let filteredFlags = try flags.filter(isIncluded)
        return FlagMap(flags: filteredFlags)
    }

    public func exposeAll() {
        self.flags.forEach { (_: String, value: FSFlag) in
            value.visitorExposed()
        }
    }
}
