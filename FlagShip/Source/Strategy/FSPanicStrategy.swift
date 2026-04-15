//
//  FSPanicStrategy.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

#if os(iOS)
import UIKit
#endif

class FSPanicStrategy: FSDefaultStrategy {
    override func updateContext(_ newContext: [String: Any]) {
        FlagshipLogManager.Log(level: .INFO, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_CONTEXT_PANIC)
    }
    
    override func sendHit(_ hit: FSTrackingProtocol) {
        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.HIT_PANIC)
    }

    override func activateFlag(_ flag: FSFlag) {
        FlagshipLogManager.Log(level: .INFO, tag: .ACTIVATE, messageToDisplay: FSLogMessage.ACTIVATE_PANIC)
    }
    
    /// Get Flag Modification value
    override func getFlagModification(_ key: String) -> FSModification? {
        return nil
    }
    
    override func getModificationInfo(_ key: String) -> [String: Any]? {
        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.GET_MODIFICATION_INFO_PANIC)
        return nil
    }
    
    override func authenticateVisitor(visitorId: String) {
        FlagshipLogManager.Log(level: .ALL, tag: .AUTHENTICATE, messageToDisplay: FSLogMessage.AUTHENTICATE_PANIC)
    }
    
    override func unAuthenticateVisitor() {
        FlagshipLogManager.Log(level: .ALL, tag: .AUTHENTICATE, messageToDisplay: FSLogMessage.UNAUTHENTICATE_PANIC)
    }
    
    /// _ Cache Visitor
    override func cacheVisitor() {}
    
    /// _ Look up visitor
    override func lookupVisitor() {}
    
    /// _ Lookup Hits
    override func lookupHits() {}
    
    /// _ Cache Hits
    //   override func saveHit(_ hitToSave: [String : Any], isActivateTracking: Bool) {}
    
#if os(iOS)

    /// _ Start collection
    override func collectEmotionsAIEvents(window: UIWindow?, screenName: String?, usingSwizzling: Bool) {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.HIT_PANIC)
    }
    
    override func onAppScreenChange(_ screenName: String) {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.HIT_PANIC)
    }
#endif
}
