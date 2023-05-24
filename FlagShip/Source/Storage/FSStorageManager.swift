//
//  FSCacheManager.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation
import SQLite3

internal class FSStorageManager {
    // Get All Event
//    class func readCampaignFromCache() -> FSCampaigns? {
//
//        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            // Path
//            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
//            // add file name
//            url.appendPathComponent("campaigns.json")
//
//            if FileManager.default.fileExists(atPath: url.path) == true {
//
//                do {
//                    // FSLogger.FSlog("read campaign from cache", .Campaign)
//
//                    let data = try Data(contentsOf: url)
//
//                    let object =  try JSONDecoder().decode(FSCampaigns.self, from: data)
//
//                    return object
//                } catch {
//
//                    // FSLogger.FSlog("Failed to read campaign from cache", .Campaign)
//                    return nil
//                }
//
//            } else {
//
//                return nil
//            }
//        }
//        return nil
//    }
    
    // Write Campaign on Directory
//    class func saveCampaignsInCache(_ data: Data?) {
//
//        if let dataCampaign = data {
//
//            DispatchQueue(label: "flagShip.saveCampaign.queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil).async {
//
//                let urlForCache: URL? = self.createUrlForCache()
//
//                guard let url = urlForCache?.appendingPathComponent("campaigns.json") else {
//
//                    // FSLogger.FSlog("Failed to save campaign", .Network)
//                    return
//                }
//                do {
//
//                    try dataCampaign.write(to: url, options: [])
//
//                } catch {
//
//                    // FSLogger.FSlog("Failed to write campaign in cache", .Network)
//                }
//            }
//
//        } else {
//
//            // FSLogger.FSlog("Failed to save campaign", .Network)
//
//            return
//        }
//    }
    
    /// Write Bucket script on directory
    
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
            FlagshipLogManager.Log(level: .ERROR, tag: .STORAGE, messageToDisplay: FSLogMessage.MESSAGE("Failed to save Bucket script"))
            // FSLogger.FSlog("", .Network)
            return
        }
    }
    
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
                    // FSLogger.FSlog("Failed to read bucket from cache", .Campaign)
                    return nil
                }
                
            } else {
                return nil
            }
        }
        return nil
    }
    
    /////////// Tools /////////////////////////////
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
                    // FSLogger.FSlog("Failed to create directory", .Network)
                    return nil
                }
                
            } else {
                return url
            }
        }
        return nil
    }
}
