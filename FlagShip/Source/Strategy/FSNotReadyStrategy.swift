//
//  FSNotReadyStrategy.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

class FSNotReadyStrategy: FSDefaultStrategy {
    override func updateContext(_ newContext: [String: Any]) {
        FlagshipLogManager.Log(level: .INFO, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_CONTEXT_NOT_READY)
    }
    
    override func synchronize(onSyncCompleted: @escaping (FSSdkStatus) -> Void) {
        FlagshipLogManager.Log(level: .INFO, tag: .SYNCHRONIZE, messageToDisplay: FSLogMessage.SYNCHRONIZE_NOT_READY)
        onSyncCompleted(.SDK_NOT_INITIALIZED)
    }
    
    override func getModification<T>(_ key: String, defaultValue: T) -> T {
        FlagshipLogManager.Log(level: .INFO, tag: .GET_MODIFICATION, messageToDisplay: FSLogMessage.GET_MODIFICATION_NOT_READY)

        return defaultValue
    }
    
    /// Get Flag Modification value
    override func getFlagModification(_ key: String) -> FSModification? {
        return nil
    }
    
    override func getModificationInfo(_ key: String) -> [String: Any]? {
        FlagshipLogManager.Log(level: .INFO, tag: .GET_MODIFICATION_INFO, messageToDisplay: FSLogMessage.GET_MODIFICATION_INFO_NOT_READY)
        return nil
    }
    
    override func activate(_ key: String) {
        FlagshipLogManager.Log(level: .INFO, tag: .ACTIVATE, messageToDisplay: FSLogMessage.ACTIVATE_NOT_READY)
    }
    
    override func sendHit(_ hit: FSTrackingProtocol) {
        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.HIT_NOT_READY)
    }
    
    /// _ Cache Visitor
    override func cacheVisitor() {}
}
