//
//  FlagBis.swift
//  Flagship
//
//  Created by Adel Ferguen on 23/04/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

public class FSFlagV4: NSObject {
    var key: String

    var strategy: FSStrategy?
    
    var timestamps: TimeInterval?
    
    private var isSafeToExpose: Bool = false
    
    public var defaultValue: Any? /// Change on the fly
    
    private var _status: FSFlagStatus {
        return strategy?.getStrategy().getFlagStatus(key) ?? .NOT_FOUND
    }
    
    public var status: FSFlagStatus {
        return _status
    }
 
    init(_ aKey: String, _ aStrategy: FSStrategy?) {
        key = aKey
        strategy = aStrategy
    }
    
    @objc public func value(defaultValue: Any?, visitorExposed: Bool = true)->Any? {
        var result: Any?
        // Update the default value
        self.defaultValue = defaultValue
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if isSameType_or_DefaultValue_Nil(defaultValue, flagModification.value) { /// _ have same type with default value OR the default value is nil
                ///
                FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The value of the flag `\(key)` is `\(flagModification.value)"))
                
                result = flagModification.value
            } else {
                result = defaultValue
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Return the default value due to the Type error"))
            }
            
            /// Activate
            if visitorExposed {
                self.visitorExposed()
            }
            return result
        }
        FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The key doon't exist ===> return the default value \(defaultValue ?? "")"))
        
        return defaultValue
    }

    #warning("Impact with TRoubleshooting, Need to adapt ")
    @objc public func visitorExposed(_ forceExposure: Bool = false) {
        /// check if the value function is called before
        
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            // Before activate we should
            // - Check if the value() is called
            
            if forceExposure {
                print(" ### Even if it seemed like there was a problem with the flag's defaultValue, you forced to send the exposure event.###")
            }
            
            let okayToExpose: Bool = isSaferExposure() || forceExposure
            
            if okayToExpose {
                strategy?.getStrategy().activateFlagV4(self)
            }
            
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Return the default value due to the Type error"))
        }
    }
    
    private func isSaferExposure()->Bool {
        isSafeToExpose ? print("It okat to expose all conditions seems to be correct ") : print("Is not recommended to expose this flag since the default value provided conflict with the value, or not provided ")
        return isSafeToExpose
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
        switch defaultValue {
        case _ as String:
            /// Compare with String
            matchedType = value is String
        case _ as Int:
            /// Compare with Int
            matchedType = value is Int
        case _ as Bool:
            /// Compare with Boolean
            matchedType = value is Bool
        case _ as Double:
            /// Compare with Double
            matchedType = value is Double
        case _ as [Any]:
            /// Compare with Array
            matchedType = value is [Any]
        case _ as [String: Any]:
            /// Compare with Dictionary
            matchedType = value is [String: Any]
        default:
            matchedType = false
        }
        
        // update is safer exposure
        isSafeToExpose = matchedType
        return matchedType
    }
}