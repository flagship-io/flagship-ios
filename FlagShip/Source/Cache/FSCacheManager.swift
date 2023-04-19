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
    @objc public init(_ visitorCacheImp: FSVisitorCacheDelegate? = nil, _ hitCacheImpl: FSHitCacheDelegate? = nil, visitorLookupTimeOut: TimeInterval = 0.2, hitCacheLookupTimeout: TimeInterval = 0.2) {
        /// Delegate for the cache visitor
        cacheVisitorDelegate = visitorCacheImp
        
        /// Delegate for the hit visitor
        hitCacheDelegate = hitCacheImpl
        
        /// Timeout for cache visitor look up
        visitorCacheLookupTimeout = visitorLookupTimeOut
    }
    
    /// Cache the visitor
    /// - Parameter visitor: visitor instance
    internal func cacheVisitor(_ visitor: FSVisitor) {
        /// Create visitor cache object
        let cacheVisitorToStore = FSCacheVisitor(visitor)
        
        /// Try Convert cacheVisitorToStore to data
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(cacheVisitorToStore)
            
            /// Tell the delegate to store this visitor cache
            cacheVisitorDelegate?.cacheVisitor(visitorId: visitor.visitorId, data)
           
        } catch {
            FlagshipLogManager.Log(level: .ALL, tag: .EXCEPTION, messageToDisplay: FSLogMessage.ERROR_ON_STORE)
        }
    }
    
    /// Retreive the visitor cached object
    /// - Parameters:
    ///   - visitoId: id of the visitor
    ///   - onCompletion: callback ob finishing the job
    public func lookupVisitorCache(visitoId: String, onCompletion: @escaping (Error?, FSCacheVisitor?)->Void) {
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
                    onCompletion(error, nil)
                }
            } else {
                onCompletion(FSError(codeError: 400, kind: .internalError), nil)
            }
            semaphore.signal()
        }
        /// complete the job event if the response for lookupVisitor still not ready
        if semaphore.wait(timeout: .now() + visitorCacheLookupTimeout) == .timedOut {
            onCompletion(FSError(codeError: 408, kind: .internalError), nil)
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
    
    internal func cacheHits(hits: [String: [String: Any]]) {
        hitCacheDelegate?.cacheHits(hits: hits)
    }
    
    internal func lookupHits(onCompletion: @escaping (Error?, [FSTrackingProtocol]?)->Void) {
        /// Create a thread
        let fsHitCacheQueue = DispatchQueue(label: "com.flagshipLookupHitCache.queue", attributes: .concurrent)
        /// Init the semaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Ask the delegate to lookup the hits
        fsHitCacheQueue.async {
            let remainedTracks = self.hitCacheDelegate?.lookupHits()
            
            // TO DO MAKE TRANSFORMATION HERE from cache model --> FSTracking
            onCompletion(nil, []) // --- TODO ----
            semaphore.signal()
        }
        /// complete the job event if the response for lookupHit still not ready
        if semaphore.wait(timeout: .now() + hitCacheLookupTimeout) == .timedOut {
            onCompletion(FSError(codeError: 408, kind: .internalError), nil)
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .TIMEOUT_CACHE_HIT)
        }
    }
    
    // Flush the given list of ids
    internal func flushHits(_ listIds: [String]) {
        hitCacheDelegate?.flushHits(hitIds: listIds)
    }

    // Flush all hits
    internal func flushAllHits() {
        hitCacheDelegate?.flushAllHits()
    }
}
