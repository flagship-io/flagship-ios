//
//  FSFlag.swift
//  Flagship
//
//  Created by Adel on 23/02/2022.
//

import Foundation
import Network

public class FSFlag:NSObject {
    
    var key             :String
    var defaultValue    :Any?
    internal var strategy:FSStrategy?

    
    internal init<T>(_ aKey:String,_ aModification:FSModification?, _ aDefaultValue:T? = nil, _ aStrategy:FSStrategy?){
        
        key            = aKey
        defaultValue   = aDefaultValue
        strategy       = aStrategy
    }
    
    
    @objc public func value(userExposed: Bool = true)->Any?{
        
        var result:Any?
        if let flagModification = strategy?.getStrategy().getFlagModification(key)  {
            
            if (self.isSameType(flagModification.value)) { ///_ have type same with default value
                ///
                FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("Return the value for flag  \(flagModification.value)"))
                
                result = flagModification.value
            }else{
                result =  defaultValue
            }
            
            /// Activate
            if userExposed{
                self.userExposed()
            }
            return result
        }
        FlagshipLogManager.Log(level: .ALL, tag: .GET_MODIFICATION, messageToDisplay: .MESSAGE("The key doon't exist ===> return the default value \(defaultValue ?? "")"))
        return defaultValue
    }
    
    @objc public func userExposed(){
        
        if let flagModification =  strategy?.getStrategy().getFlagModification(self.key){
            
            /// The activate can be activated event whatever the type if the flag's value is nil
            if (flagModification.value is NSNull || self.isSameType(flagModification.value)){
                
                /// Activate the flag
                strategy?.getStrategy().activate(self.key)
            }else{
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: .ACTIVATE_FAILED)
            }
        }
        
    }
    
    
    @objc public func exists()->Bool{
        
        return (strategy?.getStrategy().getModificationInfo(self.key) != nil)
    }
    
    
    @objc public func metadata()->FSFlagMetadata{
        
        if let flagModification =  strategy?.getStrategy().getFlagModification(self.key){
            
            if (flagModification.value is NSNull || self.isSameType(flagModification.value)){
                
                return FSFlagMetadata(flagModification)
            }
        }
        return FSFlagMetadata(nil)
    }
    
    
    
    ///_ Check the type of flag's value with the default value
    private func isSameType<T>(_ value:T)->Bool{
        
        var matchedType = false
        
        switch defaultValue {
            
        case _ as String:
            /// Compare with String
            matchedType =  value is String
            break
        case  _ as Int:
            /// Compare with Int
            matchedType = value is Int
            break
        case _ as Bool:
            /// Compare with Boolean
            matchedType =  value is Bool
            break
        case _ as Double:
            /// Compare with Double
            matchedType =  value is Double
            break
        case _ as[Any]:
            /// Compare with Array
            matchedType =  value is [Any]
            break
        case _ as [String:Any]:
            /// Compare with Dictionary
            matchedType =  value is [String:Any]
            break
        default:
            matchedType = false
        }
        
        return matchedType
    }
}



@objc public class FSFlagMetadata:NSObject{
    
    var campaignId      :String       = ""
    var variationGroupId:String       = ""
    var variationId     :String       = ""
    var isReference     :Bool         = false
    var campaignType    :String       = ""
    var slug            :String       = ""
    
    
    internal init(_ modification:FSModification?){
        
        campaignId       = modification?.campaignId       ?? ""
        variationGroupId = modification?.variationGroupId ?? ""
        variationId      = modification?.variationId      ?? ""
        isReference      = modification?.isReference      ?? false
        campaignType     = modification?.type             ?? ""
        slug             = modification?.slug             ?? ""
    }
    
    public func toJson()->[String:Any]{
        
        return      ["campaignId"           :campaignId,
                     "variationGroupId"     :variationGroupId,
                     "variationId"          :variationId,
                     "isReference"          :isReference,
                     "campaignType"         :campaignType,
                     "slug"                 : slug
                    ]
    }
}


