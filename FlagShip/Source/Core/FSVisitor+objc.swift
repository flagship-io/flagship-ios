//
//  FSVisitor+objc.swift
//  Flagship
//
//  Created by Adel on 06/04/2022.
//

import Foundation

extension FSVisitor{
    
    /// For Objective C Project, use the functions below to send Events
    /// See https://developers.flagship.io/ios/#hit-tracking
    ///
    
    
    /// Get Flag only visible for objective C, use func getFlag<T>(key:String, defaultValue : T?)->FSFlag with generic
    @available(swift, obsoleted: 1.0)
    @objc public func getFlag(key:String, defaultValue : Any?)->FSFlag{
        
        /// Check the key if exist
        guard let modification = self.currentFlags[key] else {
            
            return FSFlag(key,nil, defaultValue, self.strategy)
        }
        
        return FSFlag(key,modification, defaultValue, self.strategy)
        
    }
    

    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */
    /// sendTransactionEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc public func sendTransactionEvent(_ transacEvent: FSTransaction) {
        
        self.sendHit(transacEvent)
    }

    /**
     Send Page event
     
     @param pageEvent : Page event
     
     */
    /// sendScreenEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc public func sendScreenEvent(_ screenEvent: FSScreen) {
        
        self.sendHit(screenEvent)
    }

    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */
    /// sendItemEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc public func sendItemEvent(_ itemEvent: FSItem) {
        
        self.sendHit(itemEvent)
    }

    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    /// sendEventTrack only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc public func sendEventTrack(_ eventTrack: FSEvent) {
        
        self.sendHit(eventTrack)
    }
}
