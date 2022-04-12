//
//  FSDevice.swift
//  FlagShip-framework
//
//  Created by Adel on 10/12/2019.
//

import UIKit
import Foundation


internal class FSDevice: NSObject {

    class func getDeviceLanguage() -> String? {

        return NSLocale.current.languageCode
    }

    class func getDeviceType() -> String {

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "Mobile"
        case .pad:
            return "Tablet"
        case .tv:
            return "tv"
        default:
            return "Mobile"
        }
    }

    class func getDeviceModel() -> String {
        return UIDevice.current.name
    }
    
    class func isFirstTimeUser() -> Bool {

        let startedBefore = UserDefaults.standard.bool(forKey: "sdk_firstTimeUser")
        if startedBefore {
          
        } else {
            UserDefaults.standard.set(true, forKey: "sdk_firstTimeUser")
        }
        // FIRST_TIME_USER : TRUE (FALSE if the user is a returning one)
        return !startedBefore
    }

    class func validateIpAddress(ipToValidate: String) -> Bool {

        var sin = sockaddr_in()
        var sin6 = sockaddr_in6()

        if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
            // IPv6 peer.
            return true
        } else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            // IPv4 peer.
            return true
        }

        return false
    }
}
