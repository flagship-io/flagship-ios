//
//  FSStatus.swift
//  Flagship
//
//  Created by Adel Ferguen on 11/12/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

@objc public enum FSSdkStatus: NSInteger {
    // ----
    case SDK_NOT_INITIALIZED

    case SDK_INITIALIZING

    // ----
    case SDK_INITIALIZED

    // -----
    case SDK_PANIC

    var name: String {
        switch self { case .SDK_NOT_INITIALIZED:
            return "SDK_NOT_INITIALIZED"
        case .SDK_INITIALIZING:
            return "SDK_INITIALIZING"
        case .SDK_INITIALIZED:
            return "SDK_INITIALIZED"
        case .SDK_PANIC:
            return "SDK_PANIC"
        }
    }
}

/// This instance shoud be on the visitor instance
public enum FSFlagsStatus: String {
    case FETCHED
    case FETCHING
    case FETCH_NEEDED
    case PANIC
}

// TODO:
public enum FSFetchReasons: String {
    case UPDATE_CONTEXT
    case AUTHENTICATE
    case UNAUTHENTICATE
    case FETCH_ERROR
    case READ_FROM_CACHE
    case FAILED_ON_LAST_FETCHING

    var moreInformations: String {
        switch self {
        case .UPDATE_CONTEXT:
            ""
        case .AUTHENTICATE:
            ""
        case .UNAUTHENTICATE:
            ""
        case .FETCH_ERROR:
            ""
        case .READ_FROM_CACHE:
            ""
        }
    }
}

/// This state represent the flag entity  (without S)
public enum FSFlagStatus: String {
    case FETCHED // Flags up to date
    case FETCH_NEEDED //  - à la création mais sans cache , ou le context a changé , xpc
    case NOT_FOUND
    case PANIC
}

/// Notification center for status
///

public let FlagsStatusNotification = "FlagStatusNotification"
