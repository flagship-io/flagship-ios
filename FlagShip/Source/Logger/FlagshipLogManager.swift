//
//  FlagshipLogManager.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

public enum FSTag:String {
    
    case GLOBAL             = "GLOBAL"
    case VISITOR            = "VISITOR"
    case INITIALIZATION     = "INITIALIZATION"
    case CONFIGURATION      = "CONFIGURATION"
    case BUCKETING          = "BUCKETING"
    case UPDATE_CONTEXT     = "UPDATE_CONTEXT"
    case CLEAR_CONTEXT      = "CLEAR_CONTEXT"
    case SYNCHRONIZE        = "SYNCHRONIZE"
    case CAMPAIGNS          = "CAMPAIGNS"
    case PARSING            = "PARSING"
    case TARGETING          = "TARGETING"
    case ALLOCATION         = "ALLOCATION"
    case GET_MODIFICATION   = "GET_MODIFICATION"
    case GET_MODIFICATION_INFO = "GET_MODIFICATION_INFO"
    case TRACKING              = "HIT"
    case ACTIVATE              = "ACTIVATE"
    case AUTHENTICATE          = "AUTHENTICATE"
    case UNAUTHENTICATE        = "UNAUTHENTICATE"
    case CONSENT               = "CONSENT"
    case EXCEPTION             = "EXCEPTION"
    case STORAGE               = "STORAGE"

}


class FlagshipLogManager:FSLogManager{
    
    override init(){
        
        super.init()
    }
    
    static func Log(level: FSLevel, tag: FSTag, messageToDisplay:FSLogMessage) {
        
        if isAllowed(level){
            
            print("Flagship - \(tag.rawValue) - \(messageToDisplay.description)") /// Do not delete this print 
        }
    }
    
    static private func isAllowed(_ newLevel:FSLevel)-> Bool{
        
        let currentLevel = Flagship.sharedInstance.currentConfig.logLevel
        
        return ((newLevel.rawValue < currentLevel.rawValue) || (newLevel.rawValue == currentLevel.rawValue))
    }
    
}
