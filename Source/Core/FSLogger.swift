//
//  FSLogger.swift
//  FlagShip
//
//  Created by Adel on 27/08/2019.
//

import Foundation


enum FSLogEnum: String{
    
    
    case Campaign
    
    case Network
    
    case Parsing
}



class FSLogger{
    
    // Display Logs
    static func FSlog(_ text:String, _ type:FSLogEnum) {
        
        if  Flagship.sharedInstance.enableLogs {
            
            var printed:String
            switch type{
                
            case .Campaign:
                printed = "######## FlagShip - Campaign:" + text
                
                break
                
            case .Network:
                printed = "######## FlagShip - Network :" + text
                
                break
                
            case .Parsing:
                printed = "######## FlagShip - Parsing :" + text
                
                break
            }
            print(printed)
        }
    }
    
}
