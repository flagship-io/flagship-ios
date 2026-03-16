//
//  FlagshipTestBackgroud.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 16/03/2026.
//  Copyright © 2026 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FlagshipTestBackgroud: XCTestCase {
    override func setUp() {
        super.setUp()
        // Reset SDK state before each test so tests are independent
        Flagship.sharedInstance.reset()
    }

    override func tearDown() {
        Flagship.sharedInstance.close()
        super.tearDown()
    }

    // causing start() to return early with SDK_NOT_INITIALIZED.

    // 1. start() called from a background thread must initialize the SDK correctly
    func testStartFromBackgroundThread() {
        let exp = expectation(description: "start from background thread")

        DispatchQueue.global(qos: .background).async {
            Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "bg_test_key")
            XCTAssertEqual(Flagship.sharedInstance.envId, "gk87t3jggr10c6l6sdob",
                           "envId must be set after start() on a background thread")
            XCTAssertEqual(Flagship.sharedInstance.currentStatus, .SDK_INITIALIZED,
                           "Status must be SDK_INITIALIZED after start() on a background thread")
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    // 2. currentConfig must be readable from a background thread after start()
    func testCurrentConfigReadableFromBackgroundThread() {
        // start() on the main thread first (normal use-case), then read config from a background thread
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "bg_test_key")

        let exp = expectation(description: "config readable from background")

        DispatchQueue.global(qos: .default).async {
            let config = Flagship.sharedInstance.currentConfig
            XCTAssertNotNil(config, "currentConfig must not be nil when read from a background thread")
            XCTAssertEqual(config?.mode, .DECISION_API,
                           "testConcurrentStartFromMultipleBackgroundThreads")
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    // 3. LogManager must not crash when called from a background thread
    func testLogManagerSafeFromBackgroundThread() {
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "bg_test_key")

        let exp = expectation(description: "log from background thread")

        DispatchQueue.global(qos: .background).async {
            // Must not crash
            FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE,
                                   messageToDisplay: FSLogMessage.MESSAGE("background log test"))
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }
}
