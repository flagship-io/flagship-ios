//
//  FSTargetingManager.swift
//  FlagShip-framework
//
//  Created by Adel on 21/11/2019.
//

import UIKit


let FS_USERS = "fs_users"


enum FStargetError: Error {
    
    case unknownType
}


class FSTargetingManager: NSObject {
    
    
    internal enum FSoperator:String{
        
        case EQUAL                  = "EQUALS"
        
        case NOT_EQUAL              = "NOT_EQUALS"
        
        case GREATER_THAN           = "GREATER_THAN"
        
        case GREATER_THAN_OR_EQUALS = "GREATER_THAN_OR_EQUALS"
        
        case LOWER_THAN             = "LOWER_THAN"
        
        case LOWER_THAN_OR_EQUALS   =  "LOWER_THAN_OR_EQUALS"
        
        case CONTAINS               = "CONTAINS"
        
        case NOT_CONTAINS           = "NOT_CONTAINS"
        
        case Unknown
    }

    // Entre chanque groupe on fait OR
    // Entre chaque item on fait AND
    
    internal func isTargetingGroupIsOkay(_ targeting:FSTargeting?)->Bool{
        
        // The actual context app
        // will check if the key/value in target are the same with the context, to match audience
        //let currentContext:Dictionary <String, Any> = ABFlagShip.sharedInstance.context!.currentContext
        
        // Groupe de variations
        var booleanResultGroup:[Bool] = []
        for targetingGroup:FSTargetingGroup in targeting!.targetingGroups{
            
            booleanResultGroup.append(checkTargetGroupIsOkay(targetingGroup))
        }
        // Here we supposed to have all result , we should have at least one true value to return YES, because we have -OR- between Groups
        return booleanResultGroup.contains(true)
    }
    
    
    internal func checkTargetGroupIsOkay(_ itemTargetGroup:FSTargetingGroup)->Bool{
        
       // let currentContext:Dictionary <String, Any> = ABFlagShip.sharedInstance.context!.currentContext
        
        for itemTarget in itemTargetGroup.targetings{
            
            // Cuurent context value
          //  let currentContextValue = currentContext[itemTarget.tragetKey]
            
            let currentContextValue = self.getCurrentValueFromCtx(itemTarget.tragetKey)

            // Audience value
            let audienceValue = itemTarget.targetValue
            // Create the type operator
            let opType:FSoperator = FSoperator(rawValue: itemTarget.targetOperator) ?? .Unknown
            
            
            /// Specail tretment for array
            var isOkay:Bool = false
            if (audienceValue is [String] || audienceValue is [Int] || audienceValue is [Double] ){
                
                for subAudienceValue in audienceValue as! [Any] {
                    
                    isOkay  = checkCondition(currentContextValue as Any, opType, subAudienceValue as Any)
                    
                    if(isOkay){
                        
                        break
                    }
                }
                
            }else{
                
                    isOkay = checkCondition(currentContextValue as Any, opType, audienceValue as Any)

            }
            
            if (!isOkay){
                
                return false
            }
        }
        return true
    }
    
    
    func checkCondition(_ cuurentValue:Any, _ operation:FSoperator, _ audienceValue:Any)->Bool{
        
        switch operation {

        case .EQUAL:
            
            do {
                
                return try IsCurrentValueEqualToAudienceValue(cuurentValue, audienceValue)

            }catch{
                
                return false
            }

        case .NOT_EQUAL:
            
            do {
                
                return try !IsCurrentValueEqualToAudienceValue(cuurentValue, audienceValue)

            }catch{
                
                return false
            }

        case .GREATER_THAN:
            
            do {
                
                return try isCurrentValueIsGreaterThanAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        case .GREATER_THAN_OR_EQUALS:
            
            do {
                
                return try isCurrentValueIsGreaterThanOrEqualAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        case .LOWER_THAN:
            
            do {
                
                 return try !isCurrentValueIsGreaterThanAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        case .LOWER_THAN_OR_EQUALS:
            
            do {
                
                   return try !isCurrentValueIsGreaterThanOrEqualAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        case .CONTAINS:
            
            do {
                
                return try isCurrentValueContainAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        case .NOT_CONTAINS:
            
            do {
                
                return try !isCurrentValueContainAudience(cuurentValue, audienceValue)
                
            }catch{
                
                return false
            }
            
        default:
            return false
        }
    }
     
    
    
    /// Compare EQUALS
    
    internal func IsCurrentValueEqualToAudienceValue(_ currentValue:Any, _ audienceValue:Any) throws ->Bool{
        
        var ret:Bool = false
        
        if (currentValue is Int){
            
             ret = isEqual(type: Int.self, a: currentValue, b: audienceValue)
            
        }else if (currentValue is String){
            
            ret = isEqual(type: String.self, a: currentValue, b: audienceValue)

        }else if (currentValue is Bool){
            
            ret = isEqual(type: Bool.self, a: currentValue, b: audienceValue)
            
        }else if (currentValue is Double){
            
            ret = isEqual(type: Double.self, a: currentValue, b: audienceValue)
            
        }else if (currentValue is Float){
            
            ret = isEqual(type: Float.self, a: currentValue, b: audienceValue)

        }else {
            
            throw FStargetError.unknownType
        }
        
        return ret
    }
    
    /// Compare greater than
    
    internal func isCurrentValueIsGreaterThanAudience(_ currentValue:Any, _ audienceValue:Any) throws ->Bool{
        
        var ret:Bool = false
        
        if (currentValue is Int){
            
             ret = isGreatherThan(type: Int.self, a: currentValue, b: audienceValue)
             return ret
        }else if (currentValue is String){
            
            ret = isGreatherThan(type: String.self, a: currentValue, b: audienceValue)
            return ret
        }else{
        
            throw FStargetError.unknownType

        }
        
      //  return ret
    }
    
    /// Compare greater than or equal
    internal func isCurrentValueIsGreaterThanOrEqualAudience(_ currentValue:Any, _ audienceValue:Any) throws ->Bool{
        
        var ret:Bool = false
        
        if (currentValue is Int){
            
             ret = isGreatherThanorEqual(type: Int.self, a: currentValue, b: audienceValue)
             return ret
        }else if (currentValue is String){
            
            ret = isGreatherThanorEqual(type: String.self, a: currentValue, b: audienceValue)
            return ret
        }else{
        
            throw FStargetError.unknownType

        }
    }
    
    /// Compare contain
    internal func isCurrentValueContainAudience(_ currentValue:Any, _ audienceValue:Any) throws ->Bool{
        
        if (currentValue is String && audienceValue is String){
            
            guard let currentValue = currentValue as? String, let audienceValue = audienceValue as? String else { throw FStargetError.unknownType }

            return currentValue.contains(audienceValue)
        }else{
            
            throw FStargetError.unknownType
        }
    }
    
    
    
    
    ////// Toools ///////
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }
        
        return a == b
    }
    
    
    func isGreatherThan<T: Comparable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a > b
    }
    
    func isGreatherThanorEqual<T: Comparable>(type: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a >= b
    }
    
    
    internal func getCurrentValueFromCtx(_ targetKey:String)->Any?{
        
        let currentContext:Dictionary <String, Any> = Flagship.sharedInstance.context!.currentContext
        
        if targetKey == FS_USERS {
    
            if (Flagship.sharedInstance.visitorId != nil) {
                
                return Flagship.sharedInstance.visitorId
            }
        }else{
            
             return currentContext[targetKey]
        }
        
        return nil
    }
//    

}


