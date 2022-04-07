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

    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */

    @objc public func sendTransactionEvent(_ transacEvent: FSTransaction) {
        
        self.sendHit(transacEvent)
    }

    /**
     Send Page event
     
     @param pageEvent : Page event
     
     */
    @objc public func sendScreenEvent(_ screenEvent: FSScreen) {
        
        self.sendHit(screenEvent)
    }

    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */

    @objc public func sendItemEvent(_ itemEvent: FSItem) {
        
        self.sendHit(itemEvent)
    }

    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    @objc public func sendEventTrack(_ eventTrack: FSEvent) {
        
        self.sendHit(eventTrack)
    }
}
