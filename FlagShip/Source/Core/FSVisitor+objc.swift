//
//  FSVisitor+objc.swift
//  Flagship
//
//  Created by Adel on 06/04/2022.
//

import Foundation

public extension FSVisitor {
    /// For Objective C Project, use the functions below to send Events
    /// See https://developers.flagship.io/ios/#hit-tracking
    ///
    
    /**
     Send Transaction event
     
     @param transacEvent : Transaction event
     
     */
    /// sendTransactionEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc func sendTransactionEvent(_ transacEvent: FSTransaction) {
        self.sendHit(transacEvent)
    }

    /**
     Send Page event
     @param pageEvent : Page event
     */
    /// sendPageEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc func sendPageEvent(_ pageEvent: FSPage) {
        self.sendHit(pageEvent)
    }
    
    /// sendScreenEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc func sendScreenEvent(_ screenEvent: FSScreen) {
        self.sendHit(screenEvent)
    }

    /**
     Send Item event
     
     @param itemEvent : Item event
     
     */
    /// sendItemEvent only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc func sendItemEvent(_ itemEvent: FSItem) {
        self.sendHit(itemEvent)
    }

    /**
     Send event track
     
     @param eventTrack : track event
     
     */
    /// sendEventTrack only visible for objective C, use sendHit
    @available(swift, obsoleted: 1.0)
    @objc func sendEventTrack(_ eventTrack: FSEvent) {
        self.sendHit(eventTrack)
    }
}
