//
//  FSStatus.swift
//  Flagship
//
//  Created by Adel Ferguen on 11/12/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

@objc public enum FSSdkStatus: NSInteger {
    // When the is not started
    case SDK_NOT_INITIALIZED
    // Sdk is about to prepare the instalation
    case SDK_INITIALIZING
    // SDK is already started
    case SDK_INITIALIZED
    // The panic mode is activate
    case SDK_PANIC

    public var name: String {
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

/// This instance shoud be in the visitor instance
public enum FSFetchStatus: String {
    case FETCHED
    case FETCHING
    case FETCH_REQUIRED
    case PANIC
}

// The reason to fetch
public enum FSFetchReasons: String {
    case VISITOR_CREATE
    case UPDATE_CONTEXT
    case AUTHENTICATE
    case UNAUTHENTICATE
    case FETCH_ERROR
    case FETCHED_FROM_CACHE
    case NONE
}

/// This state represent the flag entity
public enum FSFlagStatus: String {
    case FETCHED // Flags up to date
    case FETCH_REQUIRED
    case NOT_FOUND
    case PANIC
}

/// Notification center for status

public let FlagsStatusNotification = "FlagStatusNotification"
