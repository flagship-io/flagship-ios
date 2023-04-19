//
//  AppDelegate.swift
//  QApp
//
//  Created by Adel on 20/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import AppTrackingTransparency
import Flagship
import UIKit

// @main
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    fileprivate let defaults = UserDefaults.standard
    fileprivate(set) var mainBundleDict: [String: Any]?
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        XNLogger.shared.startLogging()
        XNUIManager.shared.uiLogHandler.logFormatter.showCurlWithReqst = false
        XNUIManager.shared.uiLogHandler.logFormatter.showCurlWithResp = false

        registerSettingsBundle()


        return true
    }

    fileprivate func registerSettingsBundle() {
        guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension: "bundle") else {
            NSLog("Could not find Settings.bundle")
            return
        }

        guard let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            NSLog("Could not find Root.plist in settings bundle")
            return
        }

        guard let preferences = settings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]] else {
            NSLog("Root.plist has invalid format")
            return
        }

        var defaultsToRegister = [String: AnyObject]()
        for p in preferences {
            if let k = p["Key"] as? String, let v = p["DefaultValue"] {
                NSLog("%@", "registering \(v) for key \(k)")
                defaultsToRegister[k] = v
            }
        }

        defaults.register(defaults: defaultsToRegister)
    }
}
