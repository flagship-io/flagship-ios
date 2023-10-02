//
//  FSContinuousTrackingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 27/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class ContinuousTrackingManager: FSTrackingManager {
    // Create batch manager
    override init(_ pService: FSService, _ pTrackingConfig: FSTrackingManagerConfig, _ pCacheManager: FSCacheManager) {
        super.init(pService, pTrackingConfig, pCacheManager)

        // Get the remained hit
        cacheManager?.lookupHits(onCompletion: { error, remainedHits in
            if error == nil {
                if let aRemainedHits = remainedHits {
                    self.batchManager.reInjectElements(listToReInject: aRemainedHits)
                }
            }
        })
    }

//    /// Add Tracking element to batch - from the lookup hits
//    override func addTrackingElementsToBatch(_ listOfTracking: [FSTrackingProtocol]) {
//        // Retreive the hits
//        var cachedHits: [FSTrackingProtocol] = []
//        var cachedActivate: [FSTrackingProtocol] = []
//
//        listOfTracking.forEach { item in
//
//            if item.type == .ACTIVATE {
//                cachedActivate.append(item)
//            } else {
//                cachedHits.append(item)
//            }
//        }
//
//        if !cachedHits.isEmpty {
//            // Send batch
//            let batchForCached = FSBatch(cachedHits)
//            self.processHitsBatching(batchToSend: batchForCached)
//        }
//
//        if !cachedActivate.isEmpty {
//            let batchForCachedActivate = ActivateBatch(pCurrentActivate: nil)
//            batchForCachedActivate.addListOfElement(cachedActivate)
//            service.activate(batchForCachedActivate.bodyTrack) { error in
//                if error != nil {
//                    self.onFailedToSendActivate(batchForCachedActivate)
//                }
//            }
//        }
//    }

    // SEND HIT ---------------------//
    override func sendHit(_ hitToSend: FSTrackingProtocol) {
        if hitToSend.isValid() {
            batchManager.addTrackElement(hitToSend)
            // Save hit in Database
            let cacheHit: FSCacheHit = .init(hitToSend) // Convert to cache format
            cacheManager?.cacheHits(hits: [hitToSend.id: cacheHit.jsonCacheFormat() ?? [:]])

        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("hit not valide to be sent "))
        }
    }

    // SEND ACTIVATE --------------//
    override func sendActivate(_ currentActivate: Activate?, onCompletion: @escaping (Error?) -> Void)
    {
        // Create activate batch
        let activateBatch = ActivateBatch(pCurrentActivate: currentActivate)

        // Get the old activate if exisit
        if !batchManager.isQueueEmpty(activatePool: true) {
            activateBatch.addListOfElement(batchManager.extractAllElements(activatePool: true))
        }

        // Send Activate
        service.activate(activateBatch.bodyTrack) { error in
            if error == nil {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.ACTIVATE_SUCCESS(activateBatch.bodyTrack.description))
                self.onSucessToSendActivate(activateBatch)
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Failed to send Activate"))
                self.onFailedToSendActivate(activateBatch)
            }
            onCompletion(error)
        }
    }

    override func stopBatchingProcess() {
        batchManager.pauseBatchProcess()
    }

    override func resumeBatchingProcess() {
        batchManager.resumeBatchProcess()
    }

    // ************** BATCH PROCESS ***********//
    override internal func processActivatesBatching() {
        // We pass nil here because will batch the activate pool without a current one
        self.sendActivate(nil) { error in
            /// refractor later 
        }
    }

    // ********** HITS ************//
    override
    internal func onSucessToSendHits(_ batchToSend: FSBatch) {
        // Create a list of hits id to remove for database
        self.cacheManager?.hitCacheDelegate?.flushHits(hitIds: batchToSend.items.map { elem in
            elem.id
        })
    }

    override
    internal func onFailedToSendHits(_ batchToSend: FSBatch) {
        // Re inject the hits into the pool on failed request
        self.batchManager.reInjectElements(listToReInject: batchToSend.items)
    }

    // ********** ACTIVATE ********//
    override
    internal func onSucessToSendActivate(_ activateBatch: ActivateBatch) {
        // Create array of ids and use it by the flush database
        self.cacheManager?.flushHits(activateBatch.listActivate.map { elem in
            elem.id
        })

        // Clear all the activate present in the pool
        self.batchManager.removeTrackElements(listToRemove: activateBatch.listActivate)
    }

    override
    internal func onFailedToSendActivate(_ activateBatch: ActivateBatch) {
        // Add the current activate to batch
        self.batchManager.reInjectElements(listToReInject: activateBatch.listActivate) /// need to check if empty before

        // Add in cache the current Activate; The current activate is the first on the list activateBatch
        if let currentActivate = activateBatch.currentActivate {
            // Before add in cache we should set an Id
            self.batchManager.addTrackElement(currentActivate, activatePool: true)

            // Save hit in Database
            let cacheHit: FSCacheHit = .init(currentActivate) // Convert to cache format
            cacheManager?.cacheHits(hits: [currentActivate.id: cacheHit.jsonCacheFormat() ?? [:]])
        }
    }

    // Remove hits for visitorId and keep the consent hits
    override func flushTrackAndKeepConsent(_ visitorId: String) {
        // Remove from the pool and get the ids for the deleted ones
        let listIdsToRemove = batchManager.flushTrackAndKeepConsent(visitorId)
        if !listIdsToRemove.isEmpty {
            // Remove them fom the database
            cacheManager?.flushHits(listIdsToRemove)
        }
    }
}
