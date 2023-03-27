//
//  FSBatchingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

class FSBatchManager {
    // Define the maximum number of tracking hit that each batch can contain.
    var poolMaxSize: Int = 10
    // Each 10 seconds
    var batchIntervals: Double = 10
    // Delegate
    var delegate: FSBatchingManagerDelegate?
    // Init the poolQueue
    var fsPool: FlagshipPoolQueue = .init(10) // TO do set the param for the size limitation
    // Timer to run to manage the timinig
    var cronTimer: Timer?
    // Batch timer
    var batchTimer: FSRepeatingTimer?

    init(_ pPoolMaxSize: Int, _ pBatchIntervals: Double) {
        // Set the pool size
        poolMaxSize = pPoolMaxSize
        // Set the interval batch
        batchIntervals = pBatchIntervals
        // Init batch timer
        batchTimer = FSRepeatingTimer(timeInterval: batchIntervals)
    }

    func addTrackElement(_ newElement: FSTrackingProtocol) {
        // Add New Element if the pool
        fsPool.addNewTrackElement(newElement)

        if fsPool.count() >= poolMaxSize {
            FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("The Maximum size for queuePool is reached , process batching immediately"))
            batchFromQueue()
        }
    }

    func removeTrackElement(_ elementToRemove: FSTrackingProtocol) {
        if let idForElementToremove = elementToRemove.id {
            fsPool.removeTrackElement(idForElementToremove)
        }
    }

    func batchFromQueue() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Prcocess Batch Starting : .... 👍"))
        batchTimer?.suspend()
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE(" New Cycle Batch Procee Begin"))
        // Extract the hits from the pool and trigger the delegate
        delegate?.processBatching(batchToSend: FSBatch(fsPool.dequeueElements(poolMaxSize)))
        batchTimer?.resume()
    }

    // Start batch process
    func startBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Start Batching Process"))
        batchTimer?.eventHandler = {
            if !self.fsPool.isEmpty() {
                FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("The Duration of the periodic Batching is reached , process batching immediately"))
                self.batchFromQueue()
            }
        }
        batchTimer?.resume()
    }

    // Resume batch process
    func resumeBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Resume Batching Process"))
        batchTimer?.resume()
    }

    // Pause batch process
    func pauseBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Stop Batching Process"))
        batchTimer?.suspend()
    }
}

protocol FSBatchingManagerDelegate {
    func processBatching(batchToSend: FSBatch)
}
