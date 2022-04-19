//
//  PresetContext.swift
//  Flagship
//
//  Created by Adel on 02/03/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

import Foundation


#if os(iOS)
let OSName = UIDevice.current.systemName  // iOS
#elseif os(tvOS)
let OSName = "tvOS"
#elseif os(macOS)
let OSName = "macOS"
#elseif os(watchOS)
let OSName = "watchOS"
#else
let OSName = "iOS"
#endif



let ALL_USERS   = "fs_all_users"

/// Enumeration cases that represent **Predefined** targetings
 public enum FlagshipContext: String, CaseIterable {

    /// First init of the app
    case FIRST_TIME_INIT    = "sdk_firstTimeInit"

    /// Language of the device
    case DEVICE_LOCALE      = "sdk_deviceLanguage"

    /// Model of the device
    case DEVICE_TYPE        = "sdk_deviceType"

    /// Tablette / Mobile
    case DEVICE_MODEL       = "sdk_deviceModel"

    /// City geolocation
    case LOCATION_CITY      = "sdk_city"

    /// Region geolocation
    case LOCATION_REGION    = "sdk_region"

    /// Country geolocation
    case LOCATION_COUNTRY   = "sdk_country"

    /// Current Latitude
    case LOCATION_LAT       = "sdk_lat"

    /// Current Longitude
    case LOCATION_LONG      = "sdk_long"

    /// Ip of the device
    case IP                 = "sdk_ip"

    /// Ios
    case OS_NAME            = "sdk_osName"
     
    /// Define the current OS version name in the visitor context. Must be a String.
    case OS_VERSION_NAME        = "sdk_osVersionName"

    /// Define the current OS version code in the visitor context
    case OS_VERSION_CODE         = "sdk_osVersionCode"
     
    /// Name of the operator
    case CARRIER_NAME       = "sdk_carrierName"

    /// Is the app in debug mode?
    case DEV_MODE           = "sdk_devMode"


    /// What is the internet connection
    case INTERNET_CONNECTION = "sdk_internetConnection"

    /// Version name of the app
    case APP_VERSION_NAME   = "sdk_versionName"

    /// Version code of the app
    case APP_VERSION_CODE   = "sdk_versionCode"

    /// Version FlagShip
    case FLAGSHIP_VERSION   = "sdk_fsVersion"

    /// Name of the interface
    case INTERFACE_NAME     = "sdk_interfaceName"

    /// Get the targeting value
    public func getValue()throws ->Any? {

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
            return FlagshipContextManager.readValueFromPreDefinedContext(self)

            // Automatically set by the sdk
        case .OS_NAME:
             return OSName

            // Automatically set by the sdk
        case .OS_VERSION_CODE:
            return FSDevice.getSystemVersion()
            
        case .OS_VERSION_NAME:
            
            // set by the client
            return FlagshipContextManager.readValueFromPreDefinedContext(self)
            
            // Set by the client
        case .CARRIER_NAME:
            return FlagshipContextManager.readValueFromPreDefinedContext(self)

            /// Set by the client
        case .DEV_MODE:
              return FlagshipContextManager.readValueFromPreDefinedContext(self)

            // Automatically set by the sdk
        case .FIRST_TIME_INIT:
            return FSDevice.isFirstTimeUser()

            /// Set by the client
        case .INTERNET_CONNECTION, .APP_VERSION_NAME, .APP_VERSION_CODE :
             return FlagshipContextManager.readValueFromPreDefinedContext(self)

            /// Automatically set by the sdk
        case .FLAGSHIP_VERSION:

             return FlagShipVersion

             /// Set by the client
        case .INTERFACE_NAME:
              return FlagshipContextManager.readValueFromPreDefinedContext(self)
        }
    }

    /**
     Check Value given by the client
     
     @param valueToSet Any
     
     @return Yes is the value is valide, No otherwise
     */

    func chekcValidity(_ valueToSet: Any) -> Bool {

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

            if valueToSet is String {

                return FSDevice.validateIpAddress(ipToValidate: valueToSet as? String ?? "" )
            } else {

                return false
            }

        case .OS_NAME:
             return (valueToSet is String)

        case .OS_VERSION_CODE:
             return (valueToSet is String)
            
        case .OS_VERSION_NAME:
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

