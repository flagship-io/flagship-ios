//
//  FSCacheManager.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation
import SQLite3

class FSStorageManager {
    // Save the bucket script in the cache
    class func saveBucketScriptInCache(_ data: Data?) {
        if let bucketData = data {
            DispatchQueue(label: "flagShip.saveCampaign.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil).async {
                let urlForCache: URL? = self.createUrlForCache()

                guard let url = urlForCache?.appendingPathComponent("bucket.json") else {
                    FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay: FSLogMessage.MESSAGE("Failed to save Bucket script"))
                    return
                }
                do {
                    try bucketData.write(to: url, options: [])

                } catch {
                    FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay: FSLogMessage.MESSAGE("Failed to write bucket script in cache"))
                }
            }

        } else {
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to save Bucket script file"))

            return
        }
    }

    // Read the script of bucketing
    class func readBucketFromCache() -> FSBucket? {
        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
            // add file name
            url.appendPathComponent("bucket.json")

            if FileManager.default.fileExists(atPath: url.path) == true {
                do {
                    // FSLogger.FSlog("read bucket from cache", .Campaign)

                    let data = try Data(contentsOf: url)

                    let object = try JSONDecoder().decode(FSBucket.self, from: data)

                    return object
                } catch {
                    FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to read Bucket script file"))
                    return nil
                }

            } else {
                return nil
            }
        }
        return nil
    }

    // Tools
    class func createUrlForCache() -> URL? {
        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)

            if FileManager.default.fileExists(atPath: url.path) == false {
                // create directory
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    return url

                } catch {
                    FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to create directory"))

                    return nil
                }

            } else {
                return url
            }
        }
        return nil
    }

    class func bucketingScriptAlreadyAvailable() -> Bool {
        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
            // add file name
            url.appendPathComponent("bucket.json")

            return FileManager.default.fileExists(atPath: url.path)
        }
        return false
    }
}
