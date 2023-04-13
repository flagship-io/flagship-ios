//
//  FSBatchManagerTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 31/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSBatchManagerTest: XCTestCase, FSBatchingManagerDelegate {
    var batchManager: FSBatchManager = .init(10, 20)

    override func setUpWithError() throws {
        // Start proccess batching
        batchManager.startBatchProcess()
        batchManager.delegate = self
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddTrackElement() {
        // Add event hits
        let screen = FSScreen("test")
        screen.visitorId = "testId"

        for _ in 1 ... 9 {
            batchManager.addTrackElement(screen)
        }

        batchManager.addTrackElement(screen) // Trigger the batch , the pool should be empty
        XCTAssertTrue(batchManager.isQueueEmpty())
    }

    func processHitsBatching(batchToSend: FSBatch) {
        XCTAssertTrue(batchToSend.items.count == 10)
    }
}
