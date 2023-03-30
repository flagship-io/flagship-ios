//
//  FSPoolQueue.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation
import UIKit

class FSQueue<T> {
    private var listQueue: [T]
    
    init() {
        listQueue = Array()
    }
    
    func enqueue(_ value: T) {
        listQueue.append(value)
    }

    func dequeue() -> T? {
        guard !listQueue.isEmpty else {
            return nil
        }
        return listQueue.removeFirst()
    }
    
    func removeElement(where shouldBeRemoved: (T) throws -> Bool) rethrows {
        try listQueue.removeAll(where: shouldBeRemoved)
    }
    
    func clear() {
        listQueue.removeAll()
    }
    
    /// The number of elements in the array.
    public func count() -> Int {
        return listQueue.count
    }
    
    // Return all elements
    public func extractAllElements() -> [T] {
        let extractedList = Array(listQueue)
        clear()
        return extractedList
    }
}

class FlagshipPoolQueue {
    init(_ sizeLimitation: Int) {
        print("init FlagshipPoolQueue")
        self.sizeLimitation = sizeLimitation
    }
    
    // Queue for tracking
    var fsQueue: FSQueue<FSTrackingProtocol> = FSQueue()
    
    // Size limitation
    var sizeLimitation: Int

    // Add new elment into the queue
    func addNewTrackElement(_ newElement: FSTrackingProtocol) {
        if let visitorId = newElement.visitorId {
            newElement.id = visitorId + ":" + FSTools.generateUuidv4()
            fsQueue.enqueue(newElement)
        }
    }
    
    func reInjectElements(_ listToReInject: [FSTrackingProtocol]) {
        for item in listToReInject {
            fsQueue.enqueue(item)
        }
    }
    
    // Dequeue Elements
    func dequeueElements(_ dequeueLength: Int) -> [FSTrackingProtocol] {
        var extractedElements: [FSTrackingProtocol] = []
        var number = 0
        while number <= dequeueLength, !isEmpty() {
            if let item = fsQueue.dequeue() {
                extractedElements.append(item)
            }
            number += 1
        }
       
        return extractedElements
    }
    
    // Extract Elements and remove all elements is Queue
    func extrcatAllElements() -> [FSTrackingProtocol] {
        return fsQueue.extractAllElements()
    }

    func removeTrackElement(_ idElement: String) {
        fsQueue.removeElement { elem in
            elem.id == idElement
        }
    }
    
    func flushAllTrackFromQueue() {
        fsQueue.clear()
    }
    
    func count() -> Int {
        return fsQueue.count()
    }
    
    func isEmpty() -> Bool {
        return (fsQueue.count() == 0)
    }
}
