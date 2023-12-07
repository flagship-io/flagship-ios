//
//  FSDefaultCache.swift
//  Flagship
//
//  Created by Adel Ferguen on 03/04/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

////////////////////////////||
///                         ||
///   FSDefaultCacheVisitor ||
///                         ||
////////////////////////////||

public class FSDefaultCacheVisitor: FSVisitorCacheDelegate {
    let dbMgt_visitor: FSVisitorDbMgt

    init() {
        dbMgt_visitor = FSVisitorDbMgt()
    }

    public func lookupVisitor(visitorId: String) -> Data? {
        /// The object saved with the encoded FSCacheVisitor
        return dbMgt_visitor.readVisitorFromDB(visitorId)
    }

    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        // Save the data in DB
        if let visitorDataString = String(data: visitorData, encoding: .utf8) {
            // Delete the previous cached visitor data
            flushVisitor(visitorId: visitorId)
            // Record the latest one
            dbMgt_visitor.record_data(visitorId, data_content: visitorDataString)
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.ERROR_ON_STORE)
        }
    }

    public func flushVisitor(visitorId: String) {
        dbMgt_visitor.delete(idItemToDelete: visitorId)
    }
}

////////////////////////////||
///                         ||
///   FSDefaultCacheHit     ||
///                         ||
////////////////////////////||

public class FSDefaultCacheHit: FSHitCacheDelegate {
    let dbMgt_tracking: FSTrackingDbMgt

    init() {
        dbMgt_tracking = FSTrackingDbMgt()
    }

    // Hits represent an array of dictionary
    public func cacheHits(hits: [String: [String: Any]]) {
        hits.forEach { (key: String, value: [String: Any]) in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let stringToStore = String(data: jsonData, encoding: .utf8)
                if let aStringToStore = stringToStore {
                    dbMgt_tracking.record_data(key, data_content: aStringToStore)
                }

            } catch {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay: FSLogMessage.ERROR_ON_STORE)
                FSDataUsageTracking.sharedInstance.processTSCatchedError(v: nil, error: FlagshipError(message: "Error on Cache Hits"))
            }
        }
    }

    public func lookupHits() -> [String: [String: Any]] {
        return dbMgt_tracking.readTrackingFromDB()
    }

    public func flushHits(hitIds: [String]) {
        hitIds.forEach { hitId in
            dbMgt_tracking.delete(idItemToDelete: hitId)
        }
    }

    public func flushAllHits() {
        dbMgt_tracking.flushTable()
    }
}
