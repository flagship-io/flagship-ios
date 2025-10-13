//
//  FSCacheManager.swift
//  Flagship
//
//  Created by Adel on 28/12/2021.
//

import Foundation

/// Cache mangaer
@objc public class FSCacheManager: NSObject {
    /// Visitor cache lookup timeout in milliseconds.
    public var visitorCacheLookupTimeout: TimeInterval = 0.2 /// _ 0.2 second
    
    /// Hits cache lookup timeout in milliseconds.
    public var hitCacheLookupTimeout: TimeInterval = 0.2 /// _ 0.2 second
    
    /// Visitor cache delegate
    var cacheVisitorDelegate: FSVisitorCacheDelegate?
    
    /// Hits cache delegate
    var hitCacheDelegate: FSHitCacheDelegate?
    
    /// Init CacheManager
    /// - Parameters:
    ///   - visitorCacheImp : Implementation for cache visitor can be the default or the custom
    ///   - hitCacheImpl    : implementation for hit visitor can be the default or the custom
    ///   - visitorLookupTimeOut:Timeout when trying to get visitor
    @objc public init(_ visitorCacheImp: FSVisitorCacheDelegate? = nil, _ hitCacheImp: FSHitCacheDelegate? = nil, visitorLookupTimeOut: TimeInterval = 0.2, hitCacheLookupTimeout: TimeInterval = 0.2) {
        /// Delegate for the cache visitor
        cacheVisitorDelegate = visitorCacheImp
        
        /// Delegate for the hit visitor
        hitCacheDelegate = hitCacheImp
        
        /// Timeout for cache visitor look up
        visitorCacheLookupTimeout = visitorLookupTimeOut
    }
    
    /// Cache the visitor
    /// - Parameter visitor: visitor instance
    func cacheVisitor(_ visitor: FSVisitor) {
        /// Create visitor cache object
        let cacheVisitorToStore = FSCacheVisitor(visitor)
        /// Try Convert cacheVisitorToStore to data
        do {
            let data = try JSONEncoder().encode(cacheVisitorToStore)
            /// Tell the delegate to store this visitor cache
            cacheVisitorDelegate?.cacheVisitor(visitorId: visitor.visitorId, data)
           
        } catch {
            FlagshipLogManager.Log(level: .ALL, tag: .EXCEPTION, messageToDisplay: FSLogMessage.ERROR_ON_STORE)
            FSDataUsageTracking.sharedInstance.processTSCatchedError(v: visitor, error: FlagshipError(message: "Error on Caching Visitor"))
        }
    }
    
    /// Retreive the visitor cached object
    /// - Parameters:
    ///   - visitoId: id of the visitor
    ///   - onCompletion: callback ob finishing the job
    public func lookupVisitorCache(visitoId: String, onCompletion: @escaping (FlagshipError?, FSCacheVisitor?)->Void) {
        /// Create a thread
        let fsCacheQueue = DispatchQueue(label: "com.flagshipCache.queue", attributes: .concurrent)
        /// Init the semaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Ask the delegate to lookup the visitor
        fsCacheQueue.async {
            if let dataJson = self.cacheVisitorDelegate?.lookupVisitor(visitorId: visitoId) {
                do {
                    /// Should check the version of code before set the decoder
                    let result = try JSONDecoder().decode(FSCacheVisitor.self, from: dataJson)
                    onCompletion(nil, result)
                } catch {
                    onCompletion(FlagshipError(message: "Error on decode visitor data from cache", type: .internalError, code: 404), nil)
                }
            } else {
                onCompletion(FlagshipError(message: "The visitorId \(visitoId) not found in cache", type: .internalError, code: 400), nil)
            }
            semaphore.signal()
        }
        /// complete the job event if the response for lookupVisitor still not ready
        if semaphore.wait(timeout: .now() + visitorCacheLookupTimeout) == .timedOut {
            onCompletion(FlagshipError(type: .internalError, code: 408), nil)
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .TIMEOUT_CACHE_VISITOR)
        }
    }
    
    /// Erase the data relative to visitor
    /// - Parameter visitorId: id for the visitor
    public func flushVisitor(_ visitorId: String) {
        cacheVisitorDelegate?.flushVisitor(visitorId: visitorId)
    }
    
    //////////////////////////////
    ///                        ///
    ///         Hit Cache      ///
    ///                        ///
    //////////////////////////////
    
    func cacheHits(hits: [String: [String: Any]]) {
        hitCacheDelegate?.cacheHits(hits: hits)
    }
    
    func lookupHits(onCompletion: @escaping (Error?, [FSTrackingProtocol]?)->Void) {
        /// Create a Thread
        let fsHitCacheQueue = DispatchQueue(label: "com.flagshipLookupHitCache.queue", attributes: .concurrent)
        /// Init the semaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Ask the delegate to lookup the hits
        fsHitCacheQueue.async {
            let remainedTracks = self.hitCacheDelegate?.lookupHits()
            var cachedHitsFromDb: [FSTrackingProtocol] = []
            remainedTracks?.forEach { (id: String, value: [String: Any]) in
                do {
                    let fsCache = try JSONDecoder().decode(FSCacheHit.self, from: JSONSerialization.data(withJSONObject: value))
                    if fsCache.isLessThan4Hours() {
                        // Convert to FStrackingProtocol
                        if let convertedObject = fsCache.convertToTrackingProtocol(id) {
                            // Check if the hit still valide
                            cachedHitsFromDb.append(convertedObject)
                        }
                    } else {
                        // Remove from the DB because the hit is no longer valide
                        self.hitCacheDelegate?.flushHits(hitIds: [id])
                    }
                } catch {
                    /* Error on decode the cachehit*/
                    FSDataUsageTracking.sharedInstance.processTSCatchedError(v: nil, error: FlagshipError(message: "Error on Lookup Hits"))
                }
            }
            onCompletion(nil, cachedHitsFromDb)
            semaphore.signal()
        }
        /// complete the job event if the response for lookupHit still not ready
        if semaphore.wait(timeout: .now() + hitCacheLookupTimeout) == .timedOut {
            onCompletion(FlagshipError(type: .internalError, code: 408), nil)
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .TIMEOUT_CACHE_HIT)
        }
    }
    
    // Flush the given list of ids
    func flushHits(_ listIds: [String]) {
        hitCacheDelegate?.flushHits(hitIds: listIds)
    }

    // Flush all hits
    func flushAllHits() {
        hitCacheDelegate?.flushAllHits()
    }
}
