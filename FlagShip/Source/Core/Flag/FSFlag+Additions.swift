//
//  FSFlag+Additions.swift
//  Flagship
//
//  Created by Adel Ferguen on 04/06/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

extension FSFlag {
    func isSaferExposure() {
        var outPutMsg = ""
        if isSafeToExpose {
            outPutMsg = "It okay to expose the \"\(key)\" flag, all conditions seems to be correct"
        } else {
            if defaultValue == nil {
                outPutMsg = "Visitor \"\(strategy?.visitor.visitorId ?? "")\", the flag with the key \"\(key)\" has been exposed without calling the `getValue` method first"

            } else {
                outPutMsg = "For the visitor \"\(strategy?.visitor.visitorId ?? "")\", the flag with key \"\(key)\" has a different type compared to the default value. Therefore, the default value \"\(defaultValue ?? "")\" has been returned."
            }
        }
        FlagshipLogManager.Log(level: .INFO, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE(outPutMsg))
    }
    
    
    /// _ Objective-c
  //  @available(swift, obsoleted: 1.0)
//    @objc public func value(defaultValue: Any, visitorExposed: Bool = true) -> Any {
//        switch defaultValue {
//            case _ as String:
//                /// Compare with String
//                return self.value(defaultValue: defaultValue as? String, visitorExposed: visitorExposed) ?? defaultValue
//            case _ as Int:
//                /// Compare with Int
//                return self.value(defaultValue: defaultValue as? Int, visitorExposed: visitorExposed) ?? defaultValue
//            case _ as Bool:
//                /// Compare with Boolean
//                return self.value(defaultValue: defaultValue as? Bool, visitorExposed: visitorExposed) ?? defaultValue
//
//            case _ as Double:
//                /// Compare with Double
//                return self.value(defaultValue: defaultValue as? Double, visitorExposed: visitorExposed) ?? defaultValue
//
//            case _ as [Any]:
//                /// Compare with Array
//                return self.value(defaultValue: defaultValue as? [Any], visitorExposed: visitorExposed) ?? defaultValue
//
//            case _ as [String: Any]:
//                /// Compare with Dictionary
//                return self.value(defaultValue: defaultValue as? [String: Any], visitorExposed: visitorExposed) ?? defaultValue
//
//            default:
//                return defaultValue
//        }
//    }
}
