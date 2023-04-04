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
    
    internal func cacheHit(visitorId: String, data: Data) {
        hitCacheDelegate?.cacheHit(visitorId: visitorId, data: data)
    }
    
    internal func cacheHits(hits: [[String: [String: Any]]]) {
        hitCacheDelegate?.cacheHits(hits: hits)
    }
    
    internal func lookupHits(_ visitorId: String, onCompletion: @escaping (Error?, [FSCacheHit]?)->Void) {
        /// Create a thread
        let fsHitCacheQueue = DispatchQueue(label: "com.flagshipLookupHitCache.queue", attributes: .concurrent)
        /// Init the semaphore
        let semaphore = DispatchSemaphore(value: 0)
        
        /// Ask the delegate to lookup the hits
        fsHitCacheQueue.async {
            if let listOfData = self.hitCacheDelegate?.lookupHits(visitorId: visitorId) {
                var listOfHits: [FSCacheHit] = []
                
                for itemOfData in listOfData {
                    /// decode the array of data
                    let decoder = JSONDecoder()
                    do {
                        let cachedHit = try decoder.decode(FSCacheHit.self, from: itemOfData)
                        
                        if cachedHit.isLessThan4Hours() {
                            listOfHits.append(cachedHit)
                        }
                    } catch {
                        FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .STORAGE, messageToDisplay: .MESSAGE("Error on decode cached hit"))
                    }
                }
                
                onCompletion(nil, listOfHits)
                
            } else {
                onCompletion(FSError(codeError: 400, kind: .internalError), nil)
            }
            semaphore.signal()
        }
        /// complete the job event if the response for lookupHit still not ready
        if semaphore.wait(timeout: .now() + hitCacheLookupTimeout) == .timedOut {
            onCompletion(FSError(codeError: 408, kind: .internalError), nil)
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: .TIMEOUT_CACHE_HIT)
        }
    }
    
//    internal func flushHIts(_ visitorId: String) {
//        hitCacheDelegate?.flushHits(visitorId: visitorId)
//    }
    
    
    // Flush the given list of ids 
    internal func flushHits(_ listIds: [String]) {
        hitCacheDelegate?.flushHits(hitIds: listIds)
    }
}

//////////////////////////////||
/////                         ||
/////   FSDefaultCacheVisitor ||
/////                         ||
//////////////////////////////||
//
// public class FSDefaultCacheVisitor:FSVisitorCacheDelegate{
//
//
//    public func lookupVisitor(visitorId: String)->Data? {
//
//        /// The object saved with the encoded FSCacheVisitor
//        return FSStorage.retrieve(String(format: "%@.json",visitorId), from: .documents)
//    }
//
//    public func cacheVisitor(visitorId: String, _ ObjectToStore: Data) {
//
//        FSStorage.store(ObjectToStore, to: .documents, as: String(format: "%@.json", visitorId))
//    }
//
//    public func flushVisitor(visitorId: String) {
//        /// in FSStorage add new function to delete file's visitor
//        FSStorage.deleteFile(String(format: "%@.json", visitorId), from: .documents)
//    }
//
//
//
//
// }

// public class FSDefaultCacheHit:FSHitCacheDelegate{
//
//
//    func createUrlEventURL(_ folderName:String) -> URL? {
//
//        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            // Path
//            url.appendPathComponent("FlagshipHit/\(folderName)", isDirectory: true)
//
//            // create directory
//            do {
//                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//                return url
//
//            } catch {
//
//                return nil
//            }
//
//        } else {
//
//            return nil
//        }
//    }
//
//
//
//    public func cacheHit(visitorId: String, data: Data) {
//
//        /// Create file name
//        let formatDate = DateFormatter()
//        formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
//        let fileName = String(format: "%@.json", formatDate.string(from: Date()))
//
//        /// Folder with visitor id name
//        guard let url: URL = createUrlEventURL(visitorId)?.appendingPathComponent(fileName) else {
//
//            return
//        }
//
//        do {
//            /// write on the disk
//            try data.write(to: url, options: [])
//        } catch {
//
//            FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Failed to cache hit"))
//        }
//    }
//
//
////    public func lookupHits<T:Codable>(visitorId: String) -> [T]? {
////
////        /// The url folder
////        if let urlFolder = createUrlEventURL(visitorId){
////
////            do {
////                let listElementUrl = try FileManager.default.contentsOfDirectory(at: urlFolder, includingPropertiesForKeys: [.creationDateKey], options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants ])
////
////                var listCachedHits:[FSCacheHit] = []
////                for itemUrl in listElementUrl{
////
////                    if let cachedHit = FSStorage.retrieve(itemUrl, from: .documents, as: FSCacheHit.self){
////                        /// Check if this hit is less than 4H
////                        if (cachedHit.isLessThan4Hours()){
////                            listCachedHits.append(cachedHit)
////                        }
////                        /// Remove this item
////                        try FileManager.default.removeItem(at: itemUrl)
////                    }
////                }
////                return listCachedHits as? [T]
////            } catch {
////                FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Failed to read info track from directory"))
////                return nil
////            }
////
////        }
////        return nil
////    }
//
//    public func lookupHits(visitorId: String) -> [Data]? {
//
//        /// The url folder
//        if let urlFolder = createUrlEventURL(visitorId){
//
//            do {
//                let listElementUrl = try FileManager.default.contentsOfDirectory(at: urlFolder, includingPropertiesForKeys: [.creationDateKey], options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants ])
//
//                var listDataCachedHits:[Data] = []
//                for itemUrl in listElementUrl{
//
//                    if let cachedDataHit = FSStorage.retrieve(itemUrl, from: .documents){
//                        /// Check if this hit is less than 4H
//                      //  if (cachedHit.isLessThan4Hours()){
//                            listDataCachedHits.append(cachedDataHit)
//                     //   }
//                        /// Remove this item
//                        try FileManager.default.removeItem(at: itemUrl)
//                    }
//                }
//                return listDataCachedHits
//            } catch {
//                FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Failed to read info track from directory"))
//                return nil
//            }
//
//        }
//        return nil
//    }
//
//    public func flushHits(visitorId: String) {
//        if let urlToRemove = createUrlEventURL(visitorId){
//            do {
//                try FileManager.default.removeItem(at: urlToRemove)
//            }catch{
//                FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Failed to flush hits"))
//            }
//        }
//    }
// }
