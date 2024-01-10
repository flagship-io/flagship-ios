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
    var strategy: FSStrategy?
    
    init<T>(_ aKey: String, _ aModification: FSModification?, _ aDefaultValue: T? = nil, _ aStrategy: FSStrategy?) {
        key = aKey
        defaultValue = aDefaultValue
        strategy = aStrategy
    }
    
    @objc public func value(visitorExposed: Bool = true)->Any? {
        var result: Any?
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if isSameType_or_DefaultValue_Nil(flagModification.value){ /// _ have same type with default value OR the default value is nil
                ///
                FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The value of the flag `\(key)` is `\(flagModification.value)"))
                
                result = flagModification.value
            } else {
                result = defaultValue
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Return the default value due to the Type error"))
                
                // Send TR on not the same type flag
                FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: .GET_FLAG_VALUE_TYPE_WARNING, f: self, v: strategy?.visitor)
                return defaultValue
            }
            
            /// Activate
            if visitorExposed {
                self.visitorExposed()
            }
            return result
        }
        FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The key doon't exist ===> return the default value \(defaultValue ?? "")"))
        
        // Send TR on not found flag
        FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: .GET_FLAG_VALUE_FLAG_NOT_FOUND, f: self, v: strategy?.visitor)
        return defaultValue
    }
    
    @available(*, deprecated, message: "Use visitorExposed()")
    @objc public func userExposed() {
        visitorExposed()
    }
    
    @objc public func visitorExposed() {
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            /// The activate can be activated event whatever the type if the flag's value is nil
            if flagModification.value is NSNull || isSameType_or_DefaultValue_Nil(flagModification.value){
                /// Activate the flag
                strategy?.getStrategy().activateFlag(self)
            } else {
                // Send TR on not the same type flag
                FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: .GET_FLAG_VALUE_TYPE_WARNING, f: self, v: strategy?.visitor)
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: .ACTIVATE_FAILED)
            }
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Return the default value due to the Type error"))
            // Send TRon vistor expose and not found
            FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: .VISITOR_EXPOSED_FLAG_NO_FOUND, f: self, v: strategy?.visitor)
        }
    }
    
    @objc public func exists()->Bool {
        return (strategy?.getStrategy().getModificationInfo(key) != nil)
    }
    
    @objc public func metadata()->FSFlagMetadata {
        if let flagModification = strategy?.getStrategy().getFlagModification(key) {
            if flagModification.value is NSNull || isSameType_or_DefaultValue_Nil(flagModification.value){
                return FSFlagMetadata(flagModification)
            }
        }
        return FSFlagMetadata(nil)
    }
    
    /// _ Check the type of flag's value with the default value
    /// _ This check return true when the default value is nil
    private func isSameType_or_DefaultValue_Nil<T>(_ value: T)->Bool {
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
    public private(set) var campaignName: String = ""
    public private(set) var variationGroupName: String = ""
    public private(set) var variationName: String = ""

    init(_ modification: FSModification?) {
        campaignId = modification?.campaignId ?? ""
        variationGroupId = modification?.variationGroupId ?? ""
        variationId = modification?.variationId ?? ""
        isReference = modification?.isReference ?? false
        campaignType = modification?.type ?? ""
        slug = modification?.slug ?? ""
        campaignName = modification?.campaignName ?? ""
        variationGroupName = modification?.variationGroupName ?? ""
        variationName = modification?.variationName ?? ""
    }
    
    @objc public func toJson()->[String: Any] {
        return ["campaignId": campaignId,
                "campaignName": campaignName,
                "variationGroupId": variationGroupId,
                "variationGroupName": variationGroupName,
                "variationId": variationId,
                "variationName": variationName,
                "isReference": isReference,
                "campaignType": campaignType,
                "slug": slug]
    }
}

/**
 * This status represent the flag status depend on visitor actions
 */
@objc enum FlagSynchStatus: Int {
    // When visitor is created
    case CREATED
    // When visitor context is updated
    case CONTEXT_UPDATED
    // When visitor Fetched flags
    case FLAGS_FETCHED
    // When visitor is authenticated
    case AUTHENTICATED
    // When visitor is unauthorised
    case UNAUTHENTICATED
    
    /**
      Return the string for the flag warning message.
      Note: No message for FLAGS_FETCHED state
     */
    func warningMessage(_ flagKey: String, _ visitorId: String)->String {
        var ret = ""
        switch self {
        case .CREATED:
            ret = "Visitor `\(visitorId)` has been created without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .CONTEXT_UPDATED:
            ret = "Visitor context for visitor `\(visitorId)` has been updated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .AUTHENTICATED:
            ret = "Visitor `\(visitorId)` has been authenticated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .UNAUTHENTICATED:
            ret = "Visitor `\(visitorId)` has been unauthenticated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        default:
            break
        }
        
        return ret
    }
}
