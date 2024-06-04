//
//  FlagBis.swift
//  Flagship
//
//  Created by Adel Ferguen on 23/04/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

public class FSFlag: NSObject {
    // Key for flag modification
    var key: String
    // Strategy to stand for in any action
    var strategy: FSStrategy?
    // Safer exposure to display warning
    private var isSafeToExpose: Bool = false
    // Default value changing on the fly
    public private(set) var defaultValue: Any? /// Change on the fly
    // Current status
    private var _status: FSFlagStatus {
        return strategy?.getStrategy().getFlagStatus(key) ?? .NOT_FOUND
    }
    
    // Status value
    public var status: FSFlagStatus {
        return _status
    }
    
    // Init without a defaultValue
    init(_ aKey: String, _ aStrategy: FSStrategy?) {
        key = aKey
        strategy = aStrategy
    }
    
    /// Getting value for flag
    /// - Parameters:
    ///   - defaultValue: input given by the developer
    ///   - visitorExposed: optional input to expose flag
    /// - Returns: Return a flag value. See the documentation for more details
    
    public func value<T>(defaultValue: T?, visitorExposed: Bool = true)->T? {
        var result: T?
        // Update the default value
        self.defaultValue = defaultValue
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if isSameType_or_DefaultValue_Nil(defaultValue, flagModification.value) { /// _ have same type with default value OR the default value is nil
                ///
                FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The value of the flag `\(key)` is `\(flagModification.value)"))
                
                result = flagModification.value as? T
            } else {
                result = defaultValue
                let msg = "For the visitor \(strategy?.visitor.visitorId), no flags were found with the key \(key). Therefore, the default value \(defaultValue) has been returned"
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE(msg))
            }
            
            /// Activate
            if visitorExposed {
                self.visitorExposed()
            }
            return result
        }
        FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The key doon't exist ===> return the defaultValue"))
        
        return defaultValue
    }
    #warning("Impact with TRoubleshooting, Need to adapt ")
    @objc public func visitorExposed() {
        /// check if the value function is called before
        
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            // Before activate we should check if the value() is called to display message warning
            isSaferExposure()
            strategy?.getStrategy().activateFlag(self)
            
        } else { // The key flag not found
            FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("For the visitor \"\(strategy?.visitor.visitorId ?? "")\", no flags were found with the key \"\(key)\". As a result, user exposure will not be sent."))
            // Send TR on flag not found
            FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: .VISITOR_EXPOSED_FLAG_NOT_FOUND, f: self, v: strategy?.visitor)
        }
    }
    
    private func isSaferExposure() {
        if isSafeToExpose {
            print("It okay to expose the \(key) flag, all conditions seems to be correct ")
        } else {
            if defaultValue == nil {
                print("Visitor \"\(strategy?.visitor.visitorId ?? "")\", the flag with the key \"\(key)\" has been exposed without calling the `getValue` method first")
            } else {
                print("For the visitor \"\(strategy?.visitor.visitorId ?? "")\", the flag with key \"\(key)\" has a different type compared to the default value. Therefore, the default value \"\(defaultValue)\" has been returned.")
            }
        }
    }
    
    @objc public func exists()->Bool {
        return (strategy?.getStrategy().getModificationInfo(key) != nil)
    }
    
    @objc public func metadata()->FSFlagMetadata {
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            return FSFlagMetadata(flagModification)
        }
        return FSFlagMetadata(nil)
    }
    
    /// _ Check the type of flag's value with the default value
    /// _ This check return true when the default value is nil
    private func isSameType_or_DefaultValue_Nil<T>(_ defaultValue: T?, _ value: Any)->Bool {
        var matchedType = false
        /// If the default value given in the getFalg() is nil then the check return true
        if defaultValue == nil {
            return true
        }
        matchedType = value is T; isSafeToExpose = matchedType
        return matchedType
    }
}
