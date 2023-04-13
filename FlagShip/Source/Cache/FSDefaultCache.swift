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
    public func lookupVisitor(visitorId: String) -> Data? {
        /// The object saved with the encoded FSCacheVisitor
        return FSStorage.retrieve(String(format: "%@.json", visitorId), from: .documents)
    }

    public func cacheVisitor(visitorId: String, _ ObjectToStore: Data) {
        FSStorage.store(ObjectToStore, to: .documents, as: String(format: "%@.json", visitorId))
    }

    public func flushVisitor(visitorId: String) {
        /// in FSStorage add new function to delete file's visitor
        FSStorage.deleteFile(String(format: "%@.json", visitorId), from: .documents)
    }
}

public class FSDefaultCacheHit: FSHitCacheDelegate {
    func createUrlEventURL(_ folderName: String) -> URL? {
        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagshipHit/\(folderName)", isDirectory: true)

            // create directory
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return url

            } catch {
                return nil
            }

        } else {
            return nil
        }
    }

//    public func cacheHit(visitorId: String, data: Data) {
//        /// Create file name
//        let formatDate = DateFormatter()
//        formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
//        let fileName = String(format: "%@.json", formatDate.string(from: Date()))
//
//        /// Folder with visitor id name
//        guard let url: URL = createUrlEventURL(visitorId)?.appendingPathComponent(fileName) else {
//            return
//        }
//
//        do {
//            /// write on the disk
//            try data.write(to: url, options: [])
//        } catch {
//            FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay: FSLogMessage.MESSAGE("Failed to cache hit"))
//        }
//    }

    // Hits represent an array of dictionary
    public func cacheHits(hits: [[String: [String: Any]]]) {
        print("----------- Cache hits with a new version of Tracking Manager -----------")
    }

    public func flushHits(visitorId: String) {
        if let urlToRemove = createUrlEventURL(visitorId) {
            do {
                try FileManager.default.removeItem(at: urlToRemove)
            } catch {
                FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay: FSLogMessage.MESSAGE("Failed to flush hits"))
            }
        }
    }

    /// NEW -----
    public func lookupHits() -> [String: [String: Any]] {
        print(" ------- LOOKUP HITS ---------------")
        return ["abcdeefg": ["dl": "ios_screen",
                             "qt": 3.6893339157104492,
                             "vid": "alias",
                             "t": "SCREENVIEW", "ds": "APP",
                             "cid": "bkk9glocmjcg0vtmdlng",
                             "id": "123456788888",
                             "uip": "adresIP",
                             "cuid": "ano1",
                             "ur": "fr",
                             "sr": "200-200"],

                "abcdeefg1": ["dl": "ios_screen",
                              "qt": 3.6893339157104492,
                              "vid": "alias",
                              "t": "SCREENVIEW", "ds": "APP",
                              "cid": "bkk9glocmjcg0vtmdlng",
                              "id": "12345677888",
                              "uip": "adresIP",
                              "cuid": "ano1",
                              "ul": "fr",
                              "sr": "200-200"],
                "abcdeefg2": ["dl": "ios_screen",
                              "qt": 3.6893339157104492,
                              "vid": "alias",
                              "t": "SCREENVIEW", "ds": "APP",
                              "cid": "bkk9glocmjcg0vtmdlng", "id": "12345678688",
                              "uip": "adresIP",
                              "cuid": "ano1",
                              "ul": "fr",
                              "sr": "200-200"],
                "abcdeefg3": ["dl": "ios_screen",
                              "qt": 3.6893339157104492,
                              "vid": "alias",
                              "t": "SCREENVIEW", "ds": "APP",
                              "cid": "bkk9glocmjcg0vtmdlng",
                              "id": "12345678848",
                              "uip": "adresIP",
                              "cuid": "ano1",
                              "ur": "fr",
                              "sr": "200-200"],
                "abcdeefg4": ["dl": "ios_screen",
                              "qt": 3.6893339157104492,
                              "vid": "alias",
                              "t": "SCREENVIEW",
                              "ds": "APP",
                              "cid": "bkk9glocmjcg0vtmdlng",
                              "id": "12345678883",
                              "uip": "adresIP",
                              "cuid": "ano1",
                              "ur": "fr",
                              "sr": "200-200"]]
    }

    /// NEW -----
    public func flushHits(hitIds: [String]) {
        print(" ------- delete the given list ids from database \(hitIds)------------")
    }

    /// NEW -----
    public func flushAllHits() {}
}
