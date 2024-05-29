//
//  FlagshipConstants.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

enum FSLogMessage: CustomStringConvertible {
    /// INIT
    case INIT_SDK(_ key: String)
    case ERROR_INIT_SDK
    case ID_NULL_OR_EMPTY
    
    /// Get Modification
    case GET_MODIFICATION(_ key1: String, _ key2: String)
    case GET_MODIFICATION_PANIC
    case GET_MODIFICATION_NOT_READY
    
    /// Get Modification info
    case GET_MODIFICATION_INFO_PANIC
    case GET_MODIFICATION_INFO_NOT_READY
    
    /// Update context
    case UPDATE_CONTEXT_FAILED(_ key: String)
    case UPDATE_PRE_CONTEXT_SUCCESS(_ key: String)
    case UPDATE_PRE_CONTEXT_FAILED(_ key: String)
    case UPDATE_CONTEXT_PANIC
    case UPDATE_CONTEXT_NOT_READY
    case UPDATE_CONTEXT
    
    /// Activate
    case ACTIVATE_NO_CONSENT
    case ACTIVATE_PANIC
    case ACTIVATE_NOT_READY
    case ACTIVATE_SUCCESS(_ key: String)
    case ACTIVATE_FAILED
 
    /// Synchronize
    case SYNCHRONIZE_NOT_READY
    
    /// Hits
    case SUCCESS_SEND_HIT
    case SEND_EVENT_FAILED
    case HIT_NO_CONSENT
    case HIT_PANIC
    case HIT_NOT_READY
    
    /// Authenticate
    case AUTHENTICATE_PANIC
    case UNAUTHENTICATE_PANIC
    
    /// Others
    case ERROR_ON_READ_FLAG(_key: String)
    case NOCACHE_SCRIPT
    case IGNORE_AUTHENTICATE
    case IGNORE_UNAUTHENTICATE
    case GET_CAMPAIGN(_ key: String)
    case GET_CAMPAIGN_URL(_ key: String)
    case GET_CAMPAIGN_RESPONSE(_ key: String)
    case GET_SCRIPT_RESPONSE(_ key: String)
    case ERROR_ON_DECODE_JSON
    case BUCKETING_CODE_304
    case ERROR_ON_GET_SCRIPT
    case ERROR_HEADER
    case SUCCESS_ON_SEND_KEYS
    case FAILED_ON_SEND_KEYS
    case ERROR_ON_SERIALIZE
    case TIMEOUT_SEMEAPHORE_WAIT_POLLING
    case TIMEOUT_CACHE_HIT
    case TIMEOUT_CACHE_VISITOR

    /// Cache
    case ERROR_ON_STORE
    case ERROR_lOOKUP_CACHE
    case BUCKETING_EXISTING_FILE
    case BUCKETING_EXISTING_VARIATION(_ key: String)
    case ERROR_ON_READ_FILE
    case STORE_ACTIVATE
    case STORE_HIT
    
    /// Universal
    case MESSAGE(_ key: String?)

    var description: String {
        var ret: String
        
        switch self {
        case .MESSAGE(let key):
            ret = "\(key ?? "")"
        case .INIT_SDK(let key):
            ret = "SDK version: \(key)"
        case .GET_MODIFICATION(let key1, let key2):
            ret = "The value for key \(key1) is \(key2)"
        case .ERROR_INIT_SDK:
            ret = "Flagship SDK NOT READY"
        case .ID_NULL_OR_EMPTY:
            ret = "Identifier is empty an UUID has been generated."
        case .UPDATE_PRE_CONTEXT_FAILED(let key):
            ret = "Skip updating the context with pre configured key \(key) ..... the value is not valid"
        case .UPDATE_PRE_CONTEXT_SUCCESS(let key):
            ret = "Update context with pre configured key: \(key)"
        case .ACTIVATE_NO_CONSENT:
            ret = "Flagship, the user is not consented to send the actiavte hit"
        case .HIT_NO_CONSENT:
            ret = "Flagship, the user is not consented to send hit"
        case .UPDATE_CONTEXT_PANIC:
            ret = "Panic mode, the context is not updated"
        case .HIT_PANIC:
            ret = "Panic mode, any hit will be sent"
        case .ACTIVATE_PANIC:
            ret = "Panic mode, the activate is not sent"
        case .GET_MODIFICATION_PANIC:
            ret = "Panic mode, will return the default value"
        case .GET_MODIFICATION_INFO_PANIC:
            ret = "Panic mode, will return the default value"
        case .AUTHENTICATE_PANIC:
            ret = "AuthenticateVisitor deactivated"
        case .UNAUTHENTICATE_PANIC:
            ret = "UnAuthenticateVisitor deactivated"
        case .SEND_EVENT_FAILED:
            ret = "Failed to send event"
        case .SUCCESS_SEND_HIT:
            ret = "Hit successfully sent"
        case .UPDATE_CONTEXT_NOT_READY:
            ret = "SDK not ready to update context"
        case .SYNCHRONIZE_NOT_READY:
            ret = "SDK not ready to fetch"
        case .GET_MODIFICATION_NOT_READY:
            ret = "SDK not ready, will return default value"
        case .GET_MODIFICATION_INFO_NOT_READY:
            ret = "SDK not ready, will return nil value"
        case .ACTIVATE_NOT_READY:
            ret = "SDK not ready to send activate"
        case .HIT_NOT_READY:
            ret = "SDK not ready to send hit"
        case .ACTIVATE_SUCCESS(let key):
            ret = "Exposure sent with success ==> \(key)"
        case .ACTIVATE_FAILED:
            ret = "Error on send activate"
        case .ERROR_ON_READ_FLAG(let key):
            ret = "Something wrong with \(key)"
        case .UPDATE_CONTEXT_FAILED(let key):
            ret = "The value for the \(key) is not valide"
        case .NOCACHE_SCRIPT:
            ret = "No cached script available"
        case .IGNORE_AUTHENTICATE:
            ret = "AuthenticateVisitor method will be ignored in Bucketing configuration"
        case .IGNORE_UNAUTHENTICATE:
            ret = "UnAuthenticateVisitor method will be ignored in Bucketing configuration"
        case .GET_CAMPAIGN(let key):
            ret = "Fetching flags, the user context used is:\(key)"
        case .GET_CAMPAIGN_URL(let key):
            ret = "Fetch flags request: \(key)"
        case .GET_CAMPAIGN_RESPONSE(let key):
            ret = "Response for fetch flags is \(key)"
        case .GET_SCRIPT_RESPONSE(let key):
            ret = "The script bucketing is \(key)"
        case .ERROR_ON_DECODE_JSON:
            ret = "Error on decode Json"
        case .BUCKETING_CODE_304:
            ret = "Status 304, No need to download the bucketing script"
        case .ERROR_ON_GET_SCRIPT:
            ret = "Error on getting script"
        case .ERROR_HEADER:
            ret = "Missing information from header"
        case .SUCCESS_ON_SEND_KEYS:
            ret = "Success on sending keys / values context"
        case .FAILED_ON_SEND_KEYS:
            ret = "Failed on sending keys / values context"
        case .ERROR_ON_SERIALIZE:
            ret = "Error on serializing json"
        case .UPDATE_CONTEXT:
            ret = "Update context"
        case .ERROR_ON_STORE:
            ret = "Error on cache"
        case .ERROR_lOOKUP_CACHE:
            ret = "Error on look up visitor cache"
        case .BUCKETING_EXISTING_FILE:
            ret = "The Buketing already exist Will Re check targeting for the selected variation"
        case .ERROR_ON_READ_FILE:
            ret = "No data visitor cached"
        case .BUCKETING_EXISTING_VARIATION(let key):
            ret = "Variation Group already exist, then return the saved variation \(key)"
        case .TIMEOUT_SEMEAPHORE_WAIT_POLLING:
            ret = "Timeout for semaphore on waiting pooling to get script"
        case .TIMEOUT_CACHE_HIT:
            ret = "Timeout on lookup hit from cache"
        case .TIMEOUT_CACHE_VISITOR:
            ret = "Timeout on lookup visitor from cache"
        case .STORE_ACTIVATE:
            ret = "Saving the activate hit"
        case .STORE_HIT:
            ret = "Saving the hit"
        }
        return ret
    }
}
