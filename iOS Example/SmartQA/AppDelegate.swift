//
//  AppDelegate.swift
//  SmartQA
//
//  Created by Adel Ferguen on 19/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        do {
            var url = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            print(" -- The url path : \(url.absoluteString)")
        } catch {}
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

//class FlagshipManager {
//    static let shared = FlagshipManager()
//    var visitor: FSVisitor?
//
//    func start() {
//        Flagship.sharedInstance.start(
//            envId: "bkk9glocmjcg0vtmdlng",
//            apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23",
//            config: FSConfigBuilder()
//                .DecisionApi()
//                .withLogLevel(.ALL)
//                .build()
//        )
//
//        visitor = Flagship.sharedInstance.newVisitor("foo")
//            .isAuthenticated(true)
//            .hasConsented(hasConsented: true)
//            .build()
//
//        visitor?.fetchFlags {
//            print("xox fetch finished")
//            for i in 0 ... 3 {
//                _ = FlagshipManager.shared.visitor?.getFlag(key: "btnTitle", defaultValue: "dfl").visitorExposed()
//            }
//        }
//    }
//}
