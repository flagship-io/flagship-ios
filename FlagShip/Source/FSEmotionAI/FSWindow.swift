//
//  FSWindow.swift
//  Flagship
//
//  Created by Adel Ferguen on 20/09/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

extension UIWindow {
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }

    class func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
        switch vc {
        case is UINavigationController:
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(vc: navigationController.visibleViewController!)

        case is UITabBarController:
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)

        default:
            if let presentedViewController = vc.presentedViewController {
                // print(presentedViewController)
                if let presentedViewController2 = presentedViewController.presentedViewController {
                    return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController2)
                }
                else {
                    return vc
                }
            }
            else {
                return vc
            }
        }
    }

    func getNameForVisibleViewController() -> String? {
        if let topController = visibleViewController() {
            return NSStringFromClass(topController.classForCoder)
        }
        return nil
    }
}
#endif
