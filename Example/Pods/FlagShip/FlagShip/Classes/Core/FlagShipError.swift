//
//  FlagShipError.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation


/**
 FlagShip Error
 
 - BadPlist: wrong plist
 - ClientId_Error:   Error on client id
 - GetCampaignError: Error on get campaign
 - StoredEventError: Error on string Event
 */

@objc public enum FlagshipError:NSInteger {
    
    case None = 0
    
    case ClientId_Error
    
    case GetCampaignError
    
    case StoredEventError
}


/**
 FlagShip State
 
 - Ready   : The sdk is ready to use
 - NotReady: The not ready to use
 - Updated: The value for flagShip sdk are updated
 */


@objc public enum FlagshipState:NSInteger{
    
    case Ready = 0
    
    case NotReady
    
    case Pending
    
    case Updated
    
    case Disabled

}



enum FSError:Error{
    
    case BadPlist
}

