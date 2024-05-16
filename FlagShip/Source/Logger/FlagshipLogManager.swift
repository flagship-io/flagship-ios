//
//  FlagshipLogManager.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

public enum FSTag: String {
    case GLOBAL
    case VISITOR
    case INITIALIZATION
    case CONFIGURATION
    case BUCKETING
    case UPDATE_CONTEXT
    case CLEAR_CONTEXT
    case SYNCHRONIZE
    case CAMPAIGNS
    case PARSING
    case TARGETING
    case ALLOCATION
    case GET_MODIFICATION
    case GET_MODIFICATION_INFO
    case TRACKING = "HIT"
    case ACTIVATE
    case AUTHENTICATE
    case UNAUTHENTICATE
    case CONSENT
    case EXCEPTION
    case STORAGE = "CACHE"
    case FLAG
    case DATA_TR_USAGE
}

class FlagshipLogManager: FSLogManager {
    override init() {
        super.init()
    }

    static func Log(level: FSLevel, tag: FSTag, messageToDisplay: FSLogMessage) {
        if isAllowed(level) {
            print("Flagship - \(tag.rawValue) - \(messageToDisplay.description)") /// Do not delete this print
        }
    }

    private static func isAllowed(_ newLevel: FSLevel) -> Bool {
        let currentLevel = Flagship.sharedInstance.currentConfig.logLevel

        return (newLevel.rawValue < currentLevel.rawValue) || (newLevel.rawValue == currentLevel.rawValue)
    }
}
