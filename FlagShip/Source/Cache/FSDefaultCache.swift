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
        // return dbMgtVisitor.readVisitorData(visitorId)
        return dbMgt_visitor.readVisitorFromDB(visitorId)
    }

    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        // Save the data in DB
        if let visitorDataString = String(data: visitorData, encoding: .utf8) {
            //  dbMgtVisitor.insertVisitor(visitorId, data_content: visitorDataString)
            dbMgt_visitor.record_data(visitorId, data_content: visitorDataString)
        } else {
            // Error on converting data to json
        }
    }

    public func flushVisitor(visitorId: String) {
        /// in FSStorage add new function to delete file's visitor
        // dbMgtVisitor.delete(visitorId: visitorId)
        dbMgt_visitor.delete(idItemToDelete: visitorId)
    }
}

public class FSDefaultCacheHit: FSHitCacheDelegate {
    // let dbMgt: FSDatabaseManagment
    let dbMgt_tracking: FSTrackingDbMgt

    init() {
        //  dbMgt = FSDatabaseManagment()
        dbMgt_tracking = FSTrackingDbMgt()
    }

//    func createUrlEventURL(_ folderName: String) -> URL? {
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
//                return nil
//            }
//
//        } else {
//            return nil
//        }
//    }

    // Hits represent an array of dictionary
    public func cacheHits(hits: [String: [String: Any]]) {
        print("----------- Cache hits with a new version of Tracking Manager -----------")
        hits.forEach { (key: String, value: [String: Any]) in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let stringToStore = String(data: jsonData, encoding: .utf8)
                if let aStringToStore = stringToStore {
                    // dbMgt.insertHitMap(key, hit_content: aStringToStore)
                    dbMgt_tracking.record_data(key, data_content: aStringToStore)
                }

            } catch {
                print("error on saving hit")
            }
        }
    }

    /// NEW -----
    public func lookupHits() -> [String: [String: Any]] {
        // return dbMgt.readHitMap()
        return dbMgt_tracking.readTrackingFromDB()
    }

    /// NEW -----
    public func flushHits(hitIds: [String]) {
        hitIds.forEach { hitId in
            print(" ------- delete the hit's id from database \(hitId)------------")
            // dbMgt.delete(hitId: hitId)
            dbMgt_tracking.delete(idItemToDelete: hitId)
        }
    }

    /// NEW -----
    public func flushAllHits() {
        dbMgt_tracking.flushTable()
    }
}
