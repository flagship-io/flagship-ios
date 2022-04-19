//
//  FSTrackingManager.swift
//  Flagship
//
//  Created by Adel on 02/09/2021.
//

import Foundation


let MAX_SIZE_BATCH = 2621440  /// Bytes

internal class FSTrackingManager {
    
    var service:FSService
    
    init(_ pService:FSService){
        
        self.service = pService
    }
    
    func sendEvent< T: FSTrackingProtocol>(_ event: T, forTuple:[String:String]){
        /// Before send hit we should fill the visitorId and anonymous id
        var trackingObject = event.bodyTrack
        trackingObject.merge(forTuple) {  (_, new) in new }

        do {
            let hitData = try JSONSerialization.data(withJSONObject: trackingObject as Any, options: .prettyPrinted)
            sendDataForHit(hitData)
        }catch{
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay:FSLogMessage.SEND_EVENT_FAILED)
        }
    }
    
    
    private func sendDataForHit(_ dataHit:Data){
        
        /// Create URL
        if let urlEvent = URL(string: FSDATA_ARIANE) {
            
            self.service.sendRequest(urlEvent, type: .Tracking, data: dataHit, onCompleted: { data, error in
                
                if error == nil {
                    
                    FlagshipLogManager.Log(level: .INFO, tag:.TRACKING, messageToDisplay:FSLogMessage.SUCCESS_SEND_HIT)
                }
                
            })
        }
    }
    
    
    ///////////////
    /// BATCHS ////
    /// ///////////
    
    internal func sendBatchHits(_ listCachedHits:[FSCacheHit]){
        
        var globalSize = 0
        
        /// Core batch to send
        var coreBatch:[String:Any] = [:]
        /// Set the "cid"
        coreBatch["cid"] =  service.envId
        /// Add type
        coreBatch["t"] = "BATCH"
        /// Set the visitorId
        coreBatch["vid"] = listCachedHits.first?.data?.visitorId
        /// Set the Anonymous Id
        coreBatch["cuid"] = listCachedHits.first?.data?.anonymousId
        /// Set the data source
        coreBatch["ds"] = listCachedHits.first?.data?.content["ds"]

        
        /// Look for the hits
        var hitsArray:[Dictionary<String,Any>] = []
        for item in listCachedHits{ ///// Main Loop for hits
          
            if let dataHit = item.data {
                
                do {
                    /// Get cst time stored
                    if let savedCst = dataHit.content["cst"] as? NSNumber {
                        /// Calculate QueueTime
                        let qt: Double = Date.timeIntervalSinceReferenceDate - savedCst.doubleValue
                        /// Set QueueTime
                        dataHit.content.updateValue(qt, forKey: "qt")
                        /// Remove cst Time
                        dataHit.content.removeValue(forKey: "cst")
                    }
                    
                    /// Remove redundant information
                    dataHit.content.removeValue(forKey: "cid")
                    dataHit.content.removeValue(forKey: "ds")
                    
                    if ((globalSize + dataHit.numberOfBytes) > MAX_SIZE_BATCH){
                        
                        /// Send this array now
                        /// Add hits
                        coreBatch.updateValue(hitsArray, forKey: "h")
                        /// Send Batch
                        sendCoreBatch(coreBatch)
                        /// clean hitsArray
                        hitsArray.removeAll()
                        coreBatch.removeValue(forKey: "h")
                        globalSize = 0
                        
                    }else{
                        /// Add the hit to batch via "h"
                        hitsArray.append(dataHit.content)
                        globalSize = globalSize + dataHit.numberOfBytes
                       
                    }
                }
            }
        }
        /// if we are here and the hitsArray is not empty then send it
        if !hitsArray.isEmpty{
            /// Add hits
            coreBatch.updateValue(hitsArray, forKey: "h")
            /// Send batch
            sendCoreBatch(coreBatch)
        }
    }
    
    internal func sendCoreBatch(_ coreBatch:[String:Any]){
        do {
            let hitBatch = try JSONSerialization.data(withJSONObject: coreBatch as Any, options: .prettyPrinted)
            /// Send the core batch
            self.sendDataForHit(hitBatch)
        }catch
        {
            FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay:.MESSAGE("Failed to send batch of hits"))
        }
    }
}
