//
//  FlagShipError.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation


public enum FlagshipError:Error {
    
    case BadPlist
    
    case ClientId_Error
    
    case GetCampaignError
    
    case StoredEventError
}



public enum FlagshipState:Error {
    
    
    case Ready
    
    case NotReady
    
    case Pending
}

