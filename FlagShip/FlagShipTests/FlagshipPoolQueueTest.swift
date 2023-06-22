//
//  FlagshipPoolQueueTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 31/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FlagshipPoolQueueTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFlagshipPoolQueue() {
        let poolQueue = FlagshipPoolQueue()

        for _ in 1 ... 50 {
            let event = FSEvent(eventCategory: .Action_Tracking, eventAction: "event_test")
            event.visitorId = "alias"

            poolQueue.addNewTrackElement(event)
        }

        XCTAssert(poolQueue.isEmpty() == false)
        XCTAssert(poolQueue.count() == 50)

        let ret: [FSTrackingProtocol] = poolQueue.dequeueElements(30)
        XCTAssertTrue(ret.count == 30)
        let retBis: [FSTrackingProtocol] = poolQueue.extrcatAllElements()
        XCTAssertTrue(retBis.count == 20)

        for index in 1 ... 40 {
            let event = FSEvent(eventCategory: .Action_Tracking, eventAction: "event_test_\(index)")
            event.visitorId = "alias"
            poolQueue.addNewTrackElement(event)
        }

        if let aEvent = poolQueue.dequeueElements(1).first {
            print("The event extracted is \(aEvent.id ?? "")")
            poolQueue.removeTrackElement(aEvent.id ?? "")
            XCTAssertTrue(poolQueue.count() == 39)
            poolQueue.flushAllTrackFromQueue()
            XCTAssertTrue(poolQueue.count() == 0)
        }
    }
}
