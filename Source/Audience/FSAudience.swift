//
//  FSAudience.swift
//  FlagShip-framework
//
//  Created by Adel on 10/12/2019.
//

import UIKit
import CoreTelephony
import ClassKit
import Network



let IOS_VERSION = "iOS"
let ALL_USERS   = "fs_all_users"

public enum FSAudiences:String,CaseIterable {
    
    case FIRST_TIME_INIT    = "sdk_firstTimeInit"
    
    /// Device
    case DEVICE_LOCALE      = "sdk_deviceLanguage"
    case DEVICE_TYPE        = "sdk_deviceType"
    case DEVICE_MODEL       = "sdk_deviceModel"
    
    
    /// Location
    ///
    case LOCATION_CITY      = "sdk_city"
    case LOCATION_REGION    = "sdk_region"
    case LOCATION_COUNTRY   = "sdk_country"
    case LOCATION_LAT       = "sdk_lat"
    case LOCATION_LONG      = "sdk_long"
    case IP                 = "sdk_ip"
    
    
    ///OS_NAME
    case OS_NAME            = "sdk_osName"
    case OS_VERSION        = "sdk_iOSVersion"
    case CARRIER_NAME       = "sdk_carrierName"
    case DEV_MODE           = "sdk_devMode"
    
   
    
    
    /// USER
//    case LOGGED_IN_USER
//    case LOGGED_OUT_USER
//    case NUMBER_OF_SESSION
//    case VISITOR_ID
//    case TIME_SPENT
//    case TIME_INACTIVITY
    
    /// WIRED
    case INTERNET_CONNECTION = "sdk_internetConnection"
    
    /// APPLICATIF
    case APP_VERSION_NAME   = "sdk_versionName"
    case APP_VERSION_CODE   = "sdk_versionCode"
    case FLAGSHIP_VERSION   = "sdk_fsVersion"
    case INTERFACE_NAME     = "sdk_interfaceName"
    
    
    
    public func getValue()throws ->Any?{
        
        switch self {
            
            // Automatically set by the sdk
        case .DEVICE_LOCALE:
            return FSDevice.getDeviceLanguage()
            
            // Automatically set by the sdk
        case .DEVICE_TYPE:
            return  FSDevice.getDeviceType()
            
            // Automatically set by the sdk
        case .DEVICE_MODEL:
            return  FSDevice.getDeviceModel()
            
            /// Set by the client Geolocation
        case .LOCATION_CITY, .LOCATION_REGION, .LOCATION_COUNTRY, .LOCATION_LAT, .LOCATION_LONG, .IP:
            return FSAudience.readValueFromCurrentContext(self)
            
            // Automatically set by the sdk
        case .OS_NAME:
             return IOS_VERSION
            
            // Automatically set by the sdk
        case .OS_VERSION:
            return UIDevice.current.systemVersion
            
            // Automatically set by the sdk
        case .CARRIER_NAME:
            return FSDevice.getCarrierName()
            
            /// Set by the client
        case .DEV_MODE:
              return FSAudience.readValueFromCurrentContext(self)
            
            // Automatically set by the sdk
        case .FIRST_TIME_INIT:
            return FSDevice.isFirstTimeUser()
            
            /// Set by the client
        case .INTERNET_CONNECTION,.APP_VERSION_NAME,.APP_VERSION_CODE :
             return FSAudience.readValueFromCurrentContext(self)
            
            /// Automatically set by the sdk
        case .FLAGSHIP_VERSION:
            
             return FlagShipVersion
            
             /// Set by the client
        case .INTERFACE_NAME:
              return FSAudience.readValueFromCurrentContext(self)
        }
    }
    
    /// Check Value given by the client
    
    func chekcValidity(_ valueToSet:Any)->Bool{
        
        switch self {
            
        case .DEVICE_LOCALE:
            
            return (valueToSet is String)
            
        case .DEVICE_TYPE:
            
             return (valueToSet is String)
            
        case .DEVICE_MODEL:
            
             return (valueToSet is String)
            
            
        case .LOCATION_CITY:
            return (valueToSet is String)
            
        case .LOCATION_REGION:
            return (valueToSet is String)
            
        case .LOCATION_COUNTRY:
            return (valueToSet is String)
            
        case .LOCATION_LAT:
            return (valueToSet is Double)
            
        case .LOCATION_LONG:
            return (valueToSet is Double)
            
        case .IP:
            
            if (valueToSet is String){
                
                return FSDevice.validateIpAddress(ipToValidate:valueToSet as! String )
            }else{
                
                return false
            }
            
        case .OS_NAME:
             return (valueToSet is String)
            
        case .OS_VERSION:
             return (valueToSet is String)
        
        case .CARRIER_NAME:
             return (valueToSet is String)
            
        case .DEV_MODE:
             return (valueToSet is Bool)
            
        case .FIRST_TIME_INIT:
              return (valueToSet is Bool)
            
        case .INTERNET_CONNECTION:
             return (valueToSet is String)
            
        case .APP_VERSION_NAME:
            return (valueToSet is String)
            
        case .APP_VERSION_CODE:
            return (valueToSet is Double)
            
        case .FLAGSHIP_VERSION:
            return (valueToSet is String)
            
        case .INTERFACE_NAME:
            return (valueToSet is String)
        }
    }
    
    
}






public class FSAudience: NSObject {
    
    
    override init() {
        
        /// Scane all targetings
    }
    
    
    public class func getAudienceForApp()->[String:Any]{
        
        var resultAudience:[String:Any] = [:]
        
        
        //// Parse all keys
        
        for itemAudience in FSAudiences.allCases{
            
            do {
                
                let val = try itemAudience.getValue()
                if (val != nil){
                    
                     resultAudience.updateValue(val as Any, forKey: itemAudience.rawValue)
                    
                    FSLogger.FSlog("@@@@@@@@@@@@ Audience ---- \(itemAudience.rawValue) =  \(val ?? "Not defined") ----", .Campaign)
                    
                }
               
                
            }catch{
                
                
                FSLogger.FSlog("@@@@@@@@@@@@ Error on scane audience ---- \(itemAudience.rawValue) Not defined ----", .Campaign)

            }
        }
        return resultAudience
    }
    
    
    
    
    /// Read Value from context
    class func readValueFromCurrentContext(_ keyPreConfigured:FSAudiences)->Any?{
        
        guard let value = FlagShip.sharedInstance.context.currentContext[keyPreConfigured.rawValue]else{
            
            return nil
        }
        
        return value
    }
}
