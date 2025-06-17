//
//  FlagshipContext.swift
//  Flagship
//
//  Created by Adel on 30/11/2021.
//

import Foundation

/**

 `FlagshipContextManager` class that manage the predefined keys of context FlagshipContext (PresetContext)

 */

class FlagshipContextManager: NSObject {
    /**
     Gets all audiences values set in App

     @return key(Pre defined target)/Value
     */
    public class func getPresetContextForApp() -> [String: Any] {
        var result: [String: Any] = [:]

        /// Parse all keys
        for itemContext in FlagshipContext.allCases {
            do {
                let val = try itemContext.getValue()

                if let aVal = val {
                    result.updateValue(aVal /* as Any */, forKey: itemContext.rawValue)

                  //  FlagshipLogManager.Log(level: .INFO, tag: .TARGETING, messageToDisplay: .MESSAGE("---- \(itemContext.rawValue) =  \(val ?? "Not defined") ----"))
                }

            } catch {
                FlagshipLogManager.Log(level: .INFO, tag: .TARGETING, messageToDisplay: .MESSAGE("Error on scane audience ---- \(itemContext.rawValue) Not defined ----"))
            }
        }
        return result
    }

    /// Get value from PreDefined context
    class func readValueFromPreDefinedContext(_ keyPreConfigured: FlagshipContext) -> Any? {
        /// Return nil, because this value will be set by the dev
        return nil
    }
}
