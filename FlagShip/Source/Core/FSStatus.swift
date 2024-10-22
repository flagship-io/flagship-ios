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


// The reason to fetch
public enum FetchFlagsRequiredStatusReason: String {
    // Indicate that the visitor is created for the first time or without cache
    case FLAGS_NEVER_FETCHED
    // Indicates that a context has been updated or changed.
    case VISITOR_CONTEXT_UPDATED
    // Indicates that the XPC method 'authenticate' has been called.
    case VISITOR_AUTHENTICATED
    // Indicates that the XPC method 'unauthenticate' has been called.
    case VISITOR_UNAUTHENTICATED
    // Indicates that fetching flags has failed.
    case FLAGS_FETCHING_ERROR
    // Indicates that flags have been fetched from the cache.
    case FLAGS_FETCHED_FROM_CACHE
    // No Reason, the state should be  FETCHED,  FETCHING, PANIC
    case NONE
}

/// This state represent the flag entity
public enum FSFlagStatus: String {
    case FETCHED // Flags up to date
    case FETCHING
    case FETCH_REQUIRED
    case NOT_FOUND
    case PANIC
}
