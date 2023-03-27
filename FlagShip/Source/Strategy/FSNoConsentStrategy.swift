//
//  FSNoConsentStrategy.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

class FSNoConsentStrategy:FSDefaultStrategy{
    
    
    /// The activate is not allowed
    override func activate(_ key: String) {
        
        FlagshipLogManager.Log(level: .ALL, tag: .CONSENT, messageToDisplay:FSLogMessage.ACTIVATE_NO_CONSENT)
    }
    
    /// The send hits in not allowed, excpet the consent event 
    override func sendHit(_ hit: FSTrackingProtocol) {
        switch hit.type {
        case .CONSENT:
         //   visitor.configManager.trackingManger?.sendEvent(hit, forTuple: visitor.createTupleId())
            break
        default:
            FlagshipLogManager.Log(level: .INFO, tag: .CONSENT, messageToDisplay:FSLogMessage.HIT_NO_CONSENT)
        }
    }
    
    
    

    
    
    
    
    ///_ Cache Visitor
    override func cacheVisitor() {}
    
    ///_ Look up visitor
    override func lookupVisitor() {}
    
    /// _ Lookup Hits
    override func lookupHits() {}
    
    /// _ Cache Hits
    override func saveHit(_ hitToSave: [String : Any], isActivateTracking: Bool) {
        
        FlagshipLogManager.Log(level: .INFO, tag: .CONSENT, messageToDisplay:FSLogMessage.HIT_NO_CONSENT)

    }

}
