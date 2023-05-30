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
    override init(_ pService: FSService, _ pTrackingConfig: FSTrackingConfig, _ pCacheManager: FSCacheManager) {
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
    override func sendActivate(_ currentActivate: Activate?) {
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
        self.sendActivate(nil)
    }

    override internal func processHitsBatching(batchToSend: FSBatch) {
        do {
            let batchData = try JSONSerialization.data(withJSONObject: batchToSend.bodyTrack as Any, options: .prettyPrinted)

            FlagshipLogManager.Log(level: .ALL, tag: FSTag.TRACKING, messageToDisplay: FSLogMessage.MESSAGE(batchData.prettyPrintedJSONString as String?))

            if let urlEvent = URL(string: EVENT_TRACKING) {
                service.sendRequest(urlEvent, type: .Tracking, data: batchData, onCompleted: { _, error in

                    if error == nil {
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                        self.onSucessToSendHits(batchToSend)
                    } else {
                        self.onFailedToSendHits(batchToSend)
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
                    }
                })
            }
        } catch {
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
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
        // TODO: Check it should be gonne already on extracting the first time
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
        var listIdsToRemove = batchManager.flushTrackAndKeepConsent(visitorId)
        if !listIdsToRemove.isEmpty {
            // Remove them fom the database
            cacheManager?.flushHits(listIdsToRemove)
        }
    }
}
