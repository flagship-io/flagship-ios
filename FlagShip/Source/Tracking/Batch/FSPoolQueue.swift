//
//  FSPoolQueue.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class FSQueue<T> {
    private let queuePool = DispatchQueue(label: "batch.queue", attributes: .concurrent)
    
    private var _listQueue: [T]
    
    public var listQueue: [T] {
        get {
            return queuePool.sync {
                _listQueue
            }
        }
        set {
            queuePool.async(flags: .barrier) {
                self._listQueue = newValue
            }
        }
    }
    
    init() {
        _listQueue = Array()
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
        listQueue.count
    }
    
    // Return all elements
    public func extractAllElements() -> [T] {
        let extractedList = Array(listQueue)
        clear()
        return extractedList
    }
}

class FlagshipPoolQueue {
    // Queue for tracking
    var fsQueue: FSQueue<FSTrackingProtocol> = FSQueue()
    
    init() {}
    
    // Add new elment into the queue
    func addNewTrackElement(_ newElement: FSTrackingProtocol) {
        if let visitorId = newElement.visitorId {
            newElement.id = visitorId + ":" + FSTools.generateUuidv4()
            fsQueue.enqueue(newElement)
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("The tracking element was not added, visitorId not defined yes "))
        }
    }
    
    func reInjectElements(_ listToReInject: [FSTrackingProtocol]) {
        for item in listToReInject {
            fsQueue.enqueue(item)
        }
    }
    
    func reInjectElement(_ elemToReInject: FSTrackingProtocol) {
        fsQueue.enqueue(elemToReInject)
    }
    
    // Dequeue Elements
    func dequeueElements(_ dequeueLength: Int) -> [FSTrackingProtocol] {
        var extractedElements: [FSTrackingProtocol] = []
        var number = 1
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
    
    func removeElement(where shouldBeRemoved: (FSTrackingProtocol) throws -> Bool) rethrows {
        try fsQueue.removeElement(where: shouldBeRemoved)
    }
    
    func flushAllTrackFromQueue() {
        fsQueue.clear()
    }
    
    func count() -> Int {
        return fsQueue.count()
    }
    
    func isEmpty() -> Bool {
        return fsQueue.count() == 0
    }
}
