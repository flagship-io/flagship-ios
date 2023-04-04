//
//  FSCacheDelegate.swift
//  Flagship
//
//  Created by Adel on 28/12/2021.
//

import Foundation

@objc public protocol FSVisitorCacheDelegate: AnyObject {
    /// Called after each synchronization. Must upsert the given visitor json data in the database.
    func cacheVisitor(visitorId: String, _ visitorData: Data)
    
    /// Called right at visitor creation
    func lookupVisitor(visitorId: String) -> Data? // json data
    
    /// Called when a visitor set consent to false. Must erase visitor data related to the given visitor
    /// Id from the database.
    func flushVisitor(visitorId: String)
}

@objc public protocol FSHitCacheDelegate: AnyObject {
    
    func cacheHit(visitorId: String, data: Data)
    
    /// Lookup
    func lookupHits(visitorId: String) -> [Data]?
    
    /// Flush all hit
    func flushHits(visitorId: String)
    
    
    
    // ---------- New Interface hit implementation --------------- //
    
    // Hits represent an array of dictionary
    func cacheHits(hits: [[String: [String: Any]]])
    
    // Called to return the hits contained in the database
    // This method should timeout and be canceled  if it takes too much time. Configurable, Default 200ms
    // SDK : This method should be called at TrackingManager initialization time
    // Custom implementation : The custom implementation must load ALL the hits. Hits older than 4H should be ignored
    func lookupHits() -> [String: [String: Any]]
    
    // Called to remove the hits from the database
    // Custom implementation : It should remove the hits data corresponding to the hitIds from the database.
    func flushHits(hitIds: [String])
    
    // Called when must remove all hits in the database without exception.
    func flushAllHits()
}
