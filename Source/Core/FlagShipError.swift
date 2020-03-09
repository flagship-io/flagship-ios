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
/// :nodoc:
@objc public enum FlagshipError:NSInteger {
    
    case None = 0
    
    case ClientId_Error
    
    case GetCampaignError
    
    case StoredEventError
    
    case CetScriptError
}


/**
 FlagShip State
 
 - Ready   : The sdk is ready to use
 - NotReady: The not ready to use
 - Updated: The value for flagShip sdk are updated
 */


@objc public enum FlagShipResult:NSInteger{
   
    ///  Ready The sdk is ready to use
    case Ready = 0
    
    /// The sdk is not ready, See logs for more informations
    case NotReady
    
    /// Updated completed
    case Updated
    
    /// The sdk is disabled
    case Disabled
    
    /// 304 the file not modified
    
    case ScriptNotModified
    
}


/// :nodoc:
enum FSError:Error{
    
    case BadPlist
}

