//
//  FSFlag.swift
//  Flagship
//
//  Created by Adel on 23/02/2022.
//

import Foundation
import Network

public class FSFlag: NSObject {
    var key: String
    var defaultValue: Any?
    internal var strategy: FSStrategy?
    
    internal init<T>(_ aKey: String, _ aModification: FSModification?, _ aDefaultValue: T? = nil, _ aStrategy: FSStrategy?) {
        key = aKey
        defaultValue = aDefaultValue
        strategy = aStrategy
    }
    
    @objc public func value(visitorExposed: Bool = true)->Any? {
        var result: Any?
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if isSameType(flagModification.value) { /// _ have type same with default value
                ///
                FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("Return the value for flag  \(flagModification.value)"))
                
                result = flagModification.value
            } else {
                result = defaultValue
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
    
    @available(*, deprecated, message: "Use visitorExposed()")
    @objc public func userExposed() {
        visitorExposed()
    }
    
    @objc public func visitorExposed() {
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            /// The activate can be activated event whatever the type if the flag's value is nil
            if flagModification.value is NSNull || isSameType(flagModification.value) {
                /// Activate the flag
                strategy?.getStrategy().activateFlag(self)
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: .ACTIVATE_FAILED)
            }
        }
    }
    
    @objc public func exists()->Bool {
        return (strategy?.getStrategy().getModificationInfo(key) != nil)
    }
    
    @objc public func metadata()->FSFlagMetadata {
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if flagModification.value is NSNull || isSameType(flagModification.value) {
                return FSFlagMetadata(flagModification)
            }
        }
        return FSFlagMetadata(nil)
    }
    
    /// _ Check the type of flag's value with the default value
    private func isSameType<T>(_ value: T)->Bool {
        var matchedType = false
        
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
        
        return matchedType
    }
}

@objc public class FSFlagMetadata: NSObject {
    public private(set) var campaignId: String = ""
    public private(set) var variationGroupId: String = ""
    public private(set) var variationId: String = ""
    public private(set) var isReference: Bool = false
    public private(set) var campaignType: String = ""
    public private(set) var slug: String = ""
    
    internal init(_ modification: FSModification?) {
        campaignId = modification?.campaignId ?? ""
        variationGroupId = modification?.variationGroupId ?? ""
        variationId = modification?.variationId ?? ""
        isReference = modification?.isReference ?? false
        campaignType = modification?.type ?? ""
        slug = modification?.slug ?? ""
    }
    
    @objc public func toJson()->[String: Any] {
        return ["campaignId": campaignId,
                "variationGroupId": variationGroupId,
                "variationId": variationId,
                "isReference": isReference,
                "campaignType": campaignType,
                "slug": slug]
    }
}
