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
    let dbMgtVisitor: FSVisitorDatabaseMangment
    let dbMgtVisitorBis: FSQLiteWrapper

    init() {
        dbMgtVisitor = FSVisitorDatabaseMangment()
        dbMgtVisitorBis = FSQLiteWrapper(.DatabaseVisitor)
    }

    public func lookupVisitor(visitorId: String) -> Data? {
        /// The object saved with the encoded FSCacheVisitor
        return dbMgtVisitor.readVisitorData(visitorId)
    }

    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        // Save the data in DB
        if let visitorDataString = String(data: visitorData, encoding: .utf8) {
            dbMgtVisitor.insertVisitor(visitorId, data_content: visitorDataString)
        } else {
            // Error on converting data to json
        }
    }

    public func flushVisitor(visitorId: String) {
        /// in FSStorage add new function to delete file's visitor
        dbMgtVisitor.delete(visitorId: visitorId)
    }
}

public class FSDefaultCacheHit: FSHitCacheDelegate {
    let dbMgt: FSDatabaseManagment
    let databaseMgtHit: FSQLiteWrapper

    init() {
        dbMgt = FSDatabaseManagment()
        databaseMgtHit = FSQLiteWrapper(.DatabaseTracking)
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
                    dbMgt.insertHitMap(key, hit_content: aStringToStore)
                }

            } catch {
                print("error on saving hit")
            }
        }
    }

    /// NEW -----
    public func lookupHits() -> [String: [String: Any]] {
        return dbMgt.readHitMap()
    }

    /// NEW -----
    public func flushHits(hitIds: [String]) {
        hitIds.forEach { hitId in
            print(" ------- delete the hit's id from database \(hitId)------------")
            dbMgt.delete(hitId: hitId)
        }
    }

    /// NEW -----
    public func flushAllHits() {}
}
