//
//  FSCacheHit.swift
//  Flagship
//
//  Created by Adel on 15/02/2022.
//

import Foundation

/// 4H is the limits for hit in cahce , over this time is not valid
let TIME_DURATION_CACHE_HIT = 14400

public class FSCacheHit: Codable {
    /// Version used for migration
    var version: Double
    var data: FSHitData?
    
    private enum CodingKeys: String, CodingKey {
        case version
        case data
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.version = try values.decode(Double.self, forKey: .version) } catch { self.version = 1 }
        do { self.data = try values.decode(FSHitData.self, forKey: .data) } catch { self.data = nil }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.data, forKey: .data)
    }
    
//    init(visitorId: String, anonymousId: String?, type: String, bodyTrack: [String: Any]) {
//        self.version = 1 /// Review here
//        self.data = FSHitData(visitorId: visitorId, anonymousId: anonymousId, type: type, createdAt: 0,  bodyTrack: bodyTrack)
//    }
    
    init(_ hitToConvert: FSTrackingProtocol) {
        self.version = 1
        self.data = FSHitData(visitorId: hitToConvert.visitorId ?? "", anonymousId: hitToConvert.anonymousId, type: hitToConvert.type.typeString, createdAt: hitToConvert.createdAt, bodyTrack: hitToConvert.bodyTrack)
    }
    
    internal func isLessThan4Hours() -> Bool {
        if let dataHit = self.data {
            /// Diff of time
            let deltaTime = Date().timeIntervalSince1970 - dataHit.time
            let deltaSecond = Int(deltaTime.rounded())
            return (deltaSecond < TIME_DURATION_CACHE_HIT)
        }
        return false
    }
    
    /// Create a json format from a hit
    public func jsonCacheFormat() -> [String: Any]? {
        do {
            /// Encode cache to data
            let encodedHit = try JSONEncoder().encode(self)
            // Transform to json
            return try JSONSerialization.jsonObject(with: encodedHit, options: []) as? [String: Any]
           
        } catch {
            print("error when encoding the cache hit")
        }
        return nil
    }
    
    // Convert the cache hit to tracking manager
    func convertToTrackingProtocol(_ id: String) -> FSTrackingProtocol? {
        var newHit: FSTrackingProtocol
        if let typeOfHit = self.data?.type {
            if let aContent = self.data?.content {
                let decoder = JSONDecoder()
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: aContent)
                    switch typeOfHit {
                    case "SCREENVIEW":
                        newHit = try decoder.decode(FSScreen.self, from: jsonData)
                    case "EVENT":
                        newHit = try decoder.decode(FSEvent.self, from: jsonData)
                    case "TRANSACTION":
                        newHit = try decoder.decode(FSTransaction.self, from: jsonData)
                    case "ITEM":
                        newHit = try decoder.decode(FSItem.self, from: jsonData)
                    case "ACTIVATE":
                        newHit = try decoder.decode(Activate.self, from: jsonData)
                    default:
                        /* Error on converting the cacheHit to FStracking Protocol, because the format is unknonw */
                        return nil
                    }
                    // Set the id
                    newHit.id = id
                    newHit.createdAt = self.data?.time ?? Date().timeIntervalSince1970
                    return newHit
                    
                } catch {
                    /* Error on converting the cacheHit to FStracking Protocol*/
                }
            }
        }
        return nil
    }
}

public class FSHitData: Codable {
    /// Visitor id
    var visitorId: String
    /// Anonymous id
    var anonymousId: String?
    /// Type of hit
    var type: String
    /// TimeStamp
    var time: TimeInterval
    /// Raw data for hit
    var content: [String: Any]
    /// Number of bytes it concern only the content
    var numberOfBytes: Int
      
    private enum CodingKeys: String, CodingKey {
        case visitorId
        case anonymousId
        case type
        case time
        case content
        case numberOfBytes
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        do { self.anonymousId = try values.decode(String.self, forKey: .anonymousId) } catch { self.anonymousId = nil }
        do { self.type = try values.decode(String.self, forKey: .type) } catch { self.type = "" }
        do { self.time = try values.decode(TimeInterval.self, forKey: .time) } catch { self.time = 0 }
        /// Raw hit
        do { self.content = try values.decode([String: Any].self, forKey: .content) } catch { self.content = [:] }
        do { self.numberOfBytes = try values.decode(Int.self, forKey: .numberOfBytes) } catch { self.numberOfBytes = 0 }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.visitorId, forKey: .visitorId)
        try container.encode(self.anonymousId, forKey: .anonymousId)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.time, forKey: .time)
        try container.encode(self.content, forKey: .content)
        try container.encode(self.numberOfBytes, forKey: .numberOfBytes)
    }
    
    init(visitorId: String, anonymousId: String?, type: String, createdAt: TimeInterval, bodyTrack: [String: Any]) {
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.type = type
        /// Set timeStamp
        self.time = createdAt
        self.content = bodyTrack
        do {
            let dataTrack = try JSONSerialization.data(withJSONObject: bodyTrack, options: .prettyPrinted)
            
            self.numberOfBytes = dataTrack.count
            
        } catch {
            self.numberOfBytes = 0
        }
    }
}
