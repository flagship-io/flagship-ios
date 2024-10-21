//
//  FSBatchingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

// We added a limit to batch in order to avoid network overload
let Activate_Limit_Batch_Size: Int = 100

class FSBatchManager {
    // Define the maximum number of tracking hit that each batch can contain.
    var poolMaxSize: Int = 10
    // Each 10 seconds
    var batchIntervals: Double = 10
    // Delegate
    var delegate: FSBatchingManagerDelegate?
    // Queue for hits
    private var hitQueue: FlagshipPoolQueue
    // Queue for hits
    private var activateQueue: FlagshipPoolQueue
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
        // Create queue for hit
        hitQueue = FlagshipPoolQueue()
        // Create queue for activate
        activateQueue = FlagshipPoolQueue()
    }

    func addTrackElement(_ newElement: FSTrackingProtocol, activatePool: Bool = false) {
        // Add New Element if the pool
        if activatePool {
            activateQueue.addNewTrackElement(newElement)
        } else {
            hitQueue.addNewTrackElement(newElement)
            if hitQueue.count() >= poolMaxSize {
                FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("The Maximum size for queuePool is reached , process batching immediately"))
                batchFromQueue()
            }
        }
    }

    /// Return the list
    /// - Parameter activatePool: if true, will deal with activate queue
    /// - Returns: List of tarcking elements
    func getTrackElement(activatePool: Bool = false) -> [FSTrackingProtocol] {
        if activatePool {
            return activateQueue.fsQueue.listQueue
        } else {
            return hitQueue.fsQueue.listQueue
        }
    }

    func removeTrackElement(_ elementToRemove: FSTrackingProtocol) {
        if !elementToRemove.id.isEmpty {
            hitQueue.removeTrackElement(elementToRemove.id)
        }
    }

    func removeTrackElements(listToRemove: [FSTrackingProtocol]) {
        for elem in listToRemove {
            switch elem.type {
            case .ACTIVATE:
                activateQueue.removeTrackElement(elem.id)
            default:
                hitQueue.removeTrackElement(elem.id)
            }
        }
    }

    /// Extract (removing and retruning) all elements
    /// - Parameter activatePool: if true ==> exttract from the activate pool
    /// - Returns: all elements
    func extractAllElements(activatePool: Bool = false) -> [FSTrackingProtocol] {
        if activatePool {
            return activateQueue.dequeueElements(Activate_Limit_Batch_Size)
        } else {
            return hitQueue.extrcatAllElements()
        }
    }

    /// Reinject the tracking element into the queue
    /// - Parameter listToReInject: list of tracks elements
    func reInjectElements(listToReInject: [FSTrackingProtocol]) {
        if !listToReInject.isEmpty {
            for elem in listToReInject {
                if elem.type == .ACTIVATE {
                    activateQueue.reInjectElement(elem)
                } else {
                    hitQueue.reInjectElement(elem)
                }
            }
        }
    }

    /// Flush (Delete) all elements form the queue
    /// - Parameter activatePool: is true ==> will treat with activate queue, by default is false
    func flushPool(activatePool: Bool = false) {
        if activatePool {
            hitQueue.flushAllTrackFromQueue()
        } else {
            activateQueue.flushAllTrackFromQueue()
        }
    }

    func batchFromQueue() {
        // Batch Queue Start
        DispatchQueue.main.async {
            self.batchTimer?.suspend()
            // Process the activate pool if is not empty
            if !self.activateQueue.isEmpty() {
                self.delegate?.processActivatesBatching()
            }
            // Extract the hits from the pool and trigger the delegate
            if !self.hitQueue.isEmpty() {
                self.delegate?.processHitsBatching(batchToSend: FSBatch(self.hitQueue.dequeueElements(self.poolMaxSize)))
            }
            self.batchTimer?.resume()
        }
    }

    // Start batch process
    func startBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Start Batching Process"))
        batchTimer?.eventHandler = {
            if !self.hitQueue.isEmpty() {
                // The Duration of the Batching is reached, launch batch immediately
                self.batchFromQueue()
            }
        }
        batchTimer?.resume()
    }

    // Resume batch process
    func resumeBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Start Batching Process for Tracking"))
        batchTimer?.resume()
    }

    // Pause batch process
    func pauseBatchProcess() {
        FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Stop Batching Process for Tracking"))
        batchTimer?.suspend()
    }

    // Count of hits in the queue
    func isQueueEmpty(activatePool: Bool = false) -> Bool {
        if activatePool {
            return activateQueue.isEmpty()
        } else {
            return hitQueue.isEmpty()
        }
    }

    // Remove Hits and keep the consent
    // Return the ids for the hits to delete
    func flushTrackAndKeepConsent(_ visitorId: String) -> [String] {
        var ret: [String] = [] // result for ids to remove
        if !hitQueue.isEmpty() {
            hitQueue.removeElement { elem in

                if elem.type != .CONSENT, elem.visitorId == visitorId {
                    ret.append(elem.id)
                    return true
                } else {
                    return false
                }
            }
        }
        return ret
    }
}

protocol FSBatchingManagerDelegate {
    func processHitsBatching(batchToSend: FSBatch)
    func processActivatesBatching()
}
