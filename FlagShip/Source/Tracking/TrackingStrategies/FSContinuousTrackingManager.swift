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
    init(_ pService: FSService, _ pTrackingConfig: FSTrackingConfig, _ pCacheManager: FSCacheManager) {
        super.init(pService, pTrackingConfig)
        super.cacheManager = pCacheManager
    }

    override func sendHit(_ hitToSend: FSTrackingProtocol) {
        print("------------- SEND HIT CONTINUOUS BATCHING --------------------")
        if hitToSend.isValid() {
            batchManager.addTrackElement(hitToSend)
            // Save hit in Database
            cacheManager?.cacheHits(hits: [[hitToSend.id: hitToSend.bodyTrack]])
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("hit not valide to be sent "))
        }
    }

    override func sendActivate(_ currentActivate: Activate) {
        print("------------- SEND ACTIVATE CONTINUOUS BATCHING --------------------")
        // Create activate batch
        let activateBatch = ActivateBatch(pListActivate: [currentActivate])
        // Get the old activate if exisit
        if !batchManager.isQueueEmpty(activatePool: true) {
            activateBatch.addListOfElement(batchManager.extractAllElements(activatePool: true))
        }
        // Send Activate
        service.activate(activateBatch.bodyTrack) { error in
            if error == nil {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Activate sent with sucess"))
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Failed to send Activate"))
                // Add the current activate to batch
                self.batchManager.reInjectElements(listToReInject: activateBatch.listActivate, activatePool: true)
            }
        }
    }

    override func stopBatchingProcess() {
        batchManager.pauseBatchProcess()
    }

    override func resumeBatchingProcess() {
        batchManager.resumeBatchProcess()
    }
}
