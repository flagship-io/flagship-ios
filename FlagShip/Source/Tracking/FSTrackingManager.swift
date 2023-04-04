//
//  FSTrackingManager.swift
//  Flagship
//
//  Created by Adel on 02/09/2021.
//

import Foundation

let MAX_SIZE_BATCH = 2621440 /// Bytes

internal class FSTrackingManager: ITrackingManager, FSBatchingManagerDelegate {
    // Create batch manager
    var batchManager: FSBatchManager
    // Create service
    var service: FSService

    // Tracking config
    var trackingConfig: FSTrackingConfig

    // Interface cache hits
    var cacheManager: FSCacheManager?

    init(_ pService: FSService, _ pTrackingConfig: FSTrackingConfig) {
        service = pService
        // Set config tracking
        trackingConfig = pTrackingConfig // Revoir cette partie
        // Init the batchManager
        batchManager = FSBatchManager(trackingConfig.poolMaxSize, trackingConfig.batchIntervalTimer)
        // Set the delegate
        batchManager.delegate = self
        // Start the process
        batchManager.startBatchProcess()
    }

    private func sendDataForHit(_ dataHit: Data) {
        /// Create URL
        if let urlEvent = URL(string: EVENT_TRACKING) {
            service.sendRequest(urlEvent, type: .Tracking, data: dataHit, onCompleted: { _, error in

                if error == nil {
                    FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                }

            })
        }
    }

    // Send Hit
    func sendHit(_ hitToSend: FSTrackingProtocol) {
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: hitToSend.bodyTrack as Any, options: .prettyPrinted)
            // Send Data
            sendDataForHit(dataToSend)
        } catch {
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
        }
    }

    // Send Activate

    func sendActivate(_ currentActivate: Activate) {
        service.activate(currentActivate.bodyTrack) { error in

            if error == nil {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Activate sent with sucess"))
            } else {
                FlagshipLogManager.Log(level: .ALL, tag: .ACTIVATE, messageToDisplay: FSLogMessage.MESSAGE("Failed to send Activate"))
            }
        }
    }

    func stopBatchingProcess() {}

    func resumeBatchingProcess() {}

    // Delegate FSBatchingManagerDelegate
    func processBatching(batchToSend: FSBatch) {
        do {
            let batchData = try JSONSerialization.data(withJSONObject: batchToSend.bodyTrack as Any, options: .prettyPrinted)

            FlagshipLogManager.Log(level: .ALL, tag: FSTag.TRACKING, messageToDisplay: FSLogMessage.MESSAGE(batchData.prettyPrintedJSONString as String?))

            if let urlEvent = URL(string: EVENT_TRACKING) {
                service.sendRequest(urlEvent, type: .Tracking, data: batchData, onCompleted: { _, error in

                    if error == nil {
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SUCCESS_SEND_HIT)
                    } else {
                        FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
                    }
                })
            }
        } catch {
            FlagshipLogManager.Log(level: .ERROR, tag: .TARGETING, messageToDisplay: FSLogMessage.SEND_EVENT_FAILED)
        }
    }
}
