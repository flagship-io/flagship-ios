//
//  FSDevice.swift
//  FlagShip-framework
//
//  Created by Adel on 10/12/2019.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import IOKit
#endif
import Foundation

class FSDevice: NSObject {
    class func getDeviceLanguage() -> String? {
        return NSLocale.current.languageCode
    }
    
    /// Type od device
    class func getDeviceType() -> String {
#if os(iOS) || os(tvOS)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "Mobile"
        case .pad:
            return "Tablet"
        case .tv:
            return "TV"
        default:
            return "Mobile"
        }
#elseif os(macOS)
        return "Desktop"
#elseif os(watchOS)
        return "Watch"
#else
        return ""
#endif
    }
    
    /// Get the Model
    class func getDeviceModel() -> String {
#if os(iOS)
/// in simulaor  the system info machine return armv
#if targetEnvironment(simulator)
        return UIDevice.current.model
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
#endif
#elseif os(tvOS)
        return UIDevice.current.model
#elseif os(macOS)
        return FSDevice.getModelIdentifier() ?? "Mac"
#elseif os(watchOS)
        return WKInterfaceDevice.current().model
#else
        return ""
#endif
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
    
    class func getSystemVersion() -> String {
#if os(iOS) || os(tvOS)
        return UIDevice.current.systemVersion
#elseif os(macOS)
        return FSDevice.getOSversion()
#elseif os(watchOS)
        WKInterfaceDevice.current().systemVersion
#else
        return ""
#endif
    }
    
    class func getSystemVersionName() -> String {
#if os(iOS) || os(tvOS)
        return UIDevice.current.systemName
#elseif os(macOS)
        return FSDevice.getOSversionName()
#elseif os(watchOS)
        WKInterfaceDevice.current().systemName
#else
        return ""
#endif
    }
    
    /// Get the system version
    /// Ex: "11.6" for macOS
    class func getOSversion() -> String {
        /// Get OperatingSystemVersion
        let version = ProcessInfo().operatingSystemVersion
        /// Return the verison string
        return String(format: "%d.%d", version.majorVersion, version.minorVersion)
    }
    
    /// Get the system Name
    /// Ex: "IOS" for iphone
    class func getOSversionName() -> String {
        /// Get operatingSystemVersionString
        return ProcessInfo().operatingSystemVersionString
    }
    
#if os(macOS)
    /// Used only for macOS to get model name
    class func getModelIdentifier() -> String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }
        
        IOObjectRelease(service)
        return modelIdentifier
    }
#endif
    
    static func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        // Fallback to build number if version string not available
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1.0" // Default fallback
    }
}
