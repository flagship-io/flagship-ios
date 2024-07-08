//
//  FSTrackingManager.swift
//  Flagship
//
//  Created by Adel on 02/09/2021.
//

import Foundation

let MAX_SIZE_BATCH = 2621440 /// Bytes

class FSTrackingManager: ITrackingManager, FSBatchingManagerDelegate {
    // Create batch manager
    var batchManager: FSBatchManager
    // Create service
    var service: FSService

    // Tracking config
    var trackingConfig: FSTrackingManagerConfig

    // Interface cache hits
    var cacheManager: FSCacheManager?

    // List of the failed ids
    var failedIds: [String] = []

    init(_ pService: FSService, _ pTrackingConfig: FSTrackingManagerConfig, _ pCacheManager: FSCacheManager) {
        service = pService
        // Set config tracking
        trackingConfig = pTrackingConfig // Revoir cette partie
        // Init the batchManager
        batchManager = FSBatchManager(trackingConfig.poolMaxSize, trackingConfig.batchIntervalTimer)
        // Set the delegate
        batchManager.delegate = self
        // Start the process
        batchManager.startBatchProcess()
        // Set cacheManager
        cacheManager = pCacheManager
    }

    private func sendDataForHit(_ dataHit: Data, onCompleted: @escaping (Error?) -> Void) {
        /// Create URL
        if let urlEvent = URL(string: EVENT_TRACKING) {
            service.sendRequest(urlEvent, type: .Tracking, data: dataHit, onCompleted: { _, error in

                if error == nil {
                    FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                }
                onCompleted(error)

            })
        }
    }

    // Send Hit
    func sendHit(_ hitToSend: FSTrackingProtocol) {
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: hitToSend.bodyTrack as Any, options: .prettyPrinted)
            // Send Data
            sendDataForHit(dataToSend) { error in
                // Cache the hit on failed sending
                if error != nil {
                    self.onCacheHit(hitToSend)
                } else {
                    FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                    FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("\(dataToSend.prettyPrintedJSONString ?? "")"))
                }
            }
        } catch {
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
        }
    }

    // Send Activate

    func sendActivate(_ currentActivate: Activate, onCompletion: @escaping (Error?, [FSExposedInfo]?) -> Void) {
        service.activate(currentActivate.bodyTrack) { error in

            if error == nil {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Exposure sent with success"))
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE(currentActivate.description()))

            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Failed to send Exposure Flag"))
                self.onCacheHit(currentActivate)
            }

            onCompletion(error, nil)
        }
    }

    func stopBatchingProcess() {}

    func resumeBatchingProcess() {}

    func processActivatesBatching() {}

    func processHitsBatching(batchToSend: FSBatch) {
        do {
            let batchData = try JSONSerialization.data(withJSONObject: batchToSend.bodyTrack as Any, options: .prettyPrinted)

            FlagshipLogManager.Log(level: .ALL, tag: FSTag.TRACKING, messageToDisplay: FSLogMessage.MESSAGE(batchData.prettyPrintedJSONString as String?))

            if let urlEvent = URL(string: EVENT_TRACKING) {
                service.sendRequest(urlEvent, type: .Tracking, data: batchData, onCompleted: { _, error in

                    if error == nil {
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                        self.onSuccessToSendHits(batchToSend)
                    } else {
                        self.onFailedToSendHits(batchToSend)
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
                    }
                })
            }
        } catch {
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
            FSDataUsageTracking.sharedInstance.processTSCatchedError(v: nil, error: FlagshipError(message: "Error on Processing Hits for Batching"))
        }
    }

    // Remove hits for visitorId and keep the consent hits , Check later ...
    func flushTrackAndKeepConsent(_ visitorId: String) {
        // Remove in database all the cached hits which is the failed ones
        cacheManager?.flushHits([visitorId])
    }

    // cache the hits when the send failed
    func onCacheHit(_ itemToBeCached: FSTrackingProtocol) {
        if let aVisitorId = itemToBeCached.visitorId {
            itemToBeCached.id = aVisitorId + ":" + FSTools.generateUuidv4()
            // Save hit in Database
            let cacheHit: FSCacheHit = .init(itemToBeCached) // Convert to cache format
            cacheManager?.cacheHits(hits: [itemToBeCached.id: cacheHit.jsonCacheFormat() ?? [:]])
            // Save the id for this one, to remove it in case no consent , allow only the consent hit
            if itemToBeCached.type != .CONSENT {
                failedIds.append(itemToBeCached.id)
            }
        }
    }

    /// Add Tracking element to batch - from the lookup hits
    func addTrackingElementsToBatch(_ listOfTracking: [FSTrackingProtocol]) {
        // Retreive the hits
        var cachedHits: [FSTrackingProtocol] = []
        var cachedActivate: [FSTrackingProtocol] = []

        listOfTracking.forEach { item in

            if item.type == .ACTIVATE {
                cachedActivate.append(item)
            } else {
                cachedHits.append(item)
            }
        }

        if !cachedHits.isEmpty {
            // Send batch
            let batchForCached = FSBatch(cachedHits)
            processHitsBatching(batchToSend: batchForCached)
        }

        if !cachedActivate.isEmpty {
            let batchForCachedActivate = ActivateBatch(pCurrentActivate: nil)
            batchForCachedActivate.addListOfElement(cachedActivate)
            service.activate(batchForCachedActivate.bodyTrack) { error in
                if error != nil {
                    self.onFailedToSendActivate(batchForCachedActivate)
                } else {
                    self.onSuccessToSendActivate(batchForCachedActivate)
                }
            }
        }
    }

    // ********** HITS ************//
    func onSuccessToSendHits(_ batchToSend: FSBatch) {
        // Create a list of hits id to remove for database
        cacheManager?.hitCacheDelegate?.flushHits(hitIds: batchToSend.items.map { elem in
            elem.id
        })
    }

    func onFailedToSendHits(_ batchToSend: FSBatch) {
        // Do nothing, will try on the next init
    }

    // ********** ACTIVATES ************//
    func onSuccessToSendActivate(_ activateBatch: ActivateBatch) {
        cacheManager?.flushHits(activateBatch.listActivate.map { elem in
            elem.id
        })
    }

    func onFailedToSendActivate(_ activateBatch: ActivateBatch) {
        // Do nothing, will try on the next init
    }
}
