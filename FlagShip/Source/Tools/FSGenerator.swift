//
//  FSGenerator.swift
//  FlagShip
//
//  Created by Adel on 23/10/2019.
//

import Foundation

// FlagShip id
let FlagShipIdKey   = "FlagShipIdKey"

class FSGenerator: NSObject {

    /// Generate
    internal class func generateFlagShipId() -> String {

        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyyMMddHHmmss"
        return String(format: "%@%d", formatDate.string(from: Date()), Int.random(in: 10000..<99999))
    }

    /// Save UserId in cache user default
    internal class func saveFlagShipIdInCache(userId: String) {

        UserDefaults.standard.setValue(userId, forKey: FlagShipIdKey)
    }

    /// get FlagShip id from user default
    internal class func getFlagShipIdInCache() -> String? {

         UserDefaults.standard.string(forKey: FlagShipIdKey)
    }

    /// Reset FlagShip internUserID
    internal class func resetFlagShipIdInCache() {

        UserDefaults.standard.removeObject(forKey: FlagShipIdKey)
    }

}
