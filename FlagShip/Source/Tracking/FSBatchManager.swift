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

    var onProcess: (() -> Void)? /// callBack

    init() {
        // Init batch timer
        batchTimer = FSRepeatingTimer(timeInterval: batchIntervals)
    }

    func addTrackElement(_ newElement: FSTrackingProtocol) {
        // Add New Element if the pool
        fsPool.addNewTrackElement(newElement)

        if fsPool.count() >= poolMaxSize {
            print("@@@@@@@@@@@ The size limit for the pool is reached , will process btaching ")
            batchFromQueue()
        }
    }

    func removeTrackElement(_ elementToRemove: FSTrackingProtocol) {
        if let idForElementToremove = elementToRemove.id {
            fsPool.removeTrackElement(idForElementToremove)
        }
    }

    func batchFromQueue() {
        batchTimer?.suspend()
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE(" New Cycle Batch Procee Begin"))
        // Extract the hits from the pool
        var result = fsPool.dequeueElements(poolMaxSize)

        if !result.isEmpty {
            // Create a batch object
        }
        print("@@@@@@@@@@@@@@ The size of extracted pool is \(result.count) @@@@@@@@@@@@@@@@@@@@")
        delegate?.processBatching(batchToSend: FSBatch(result))
        batchTimer?.resume()
    }

    // Start batch process
    func startBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Start Batching Process"))
        batchTimer?.eventHandler = {
            if !self.fsPool.isEmpty() {
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
