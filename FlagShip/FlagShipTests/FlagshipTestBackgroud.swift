//
//  FlagshipTestBackgroud.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 16/03/2026.
//  Copyright © 2026 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

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
    private let validEnvId  = "gk87t3jggr10c6l6sdob" // 20 chars, same as other test files

    // 1. start() called from a background thread must initialize the SDK correctly
    func testStartFromBackgroundThread() {
        let exp = expectation(description: "start from background thread")

        DispatchQueue.global(qos: .background).async {
            Flagship.sharedInstance.start(envId: self.validEnvId, apiKey: "bg_test_key")
            XCTAssertEqual(Flagship.sharedInstance.envId, self.validEnvId,
                           "envId must be set after start() on a background thread")
            XCTAssertEqual(Flagship.sharedInstance.apiKey, "bg_test_key",
                           "apiKey must be set after start() on a background thread")
            XCTAssertEqual(Flagship.sharedInstance.currentStatus, .SDK_INITIALIZED,
                           "Status must be SDK_INITIALIZED after start() on a background thread")
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // 2. currentConfig must be readable from a background thread after start()
    func testCurrentConfigReadableFromBackgroundThread() {
        // start() on the main thread first (normal use-case), then read config from a background thread
        Flagship.sharedInstance.start(envId: validEnvId, apiKey: "bg_test_key")

        let exp = expectation(description: "config readable from background")

        DispatchQueue.global(qos: .background).async {
            let config = Flagship.sharedInstance.currentConfig
            XCTAssertNotNil(config, "currentConfig must not be nil when read from a background thread")
            XCTAssertEqual(config?.mode, .DECISION_API,
                           "Default mode must be DECISION_API when read from a background thread")
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // 3. LogManager must not crash when called from a background thread
    func testLogManagerSafeFromBackgroundThread() {
        Flagship.sharedInstance.start(envId: validEnvId, apiKey: "bg_test_key")

        let exp = expectation(description: "log from background thread")

        DispatchQueue.global(qos: .background).async {
            // Must not crash
            FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE,
                                   messageToDisplay: FSLogMessage.MESSAGE("background log test"))
            exp.fulfill()
        }

        waitForExpectations(timeout: 5)
    }

    // 4. Concurrent start() calls from multiple background threads must not deadlock or crash
    func testConcurrentStartFromMultipleBackgroundThreads() {
        let group = DispatchGroup()
        let queues: [DispatchQoS.QoSClass] = [.background, .utility, .userInitiated, .userInteractive, .default]

        for (_, qos) in queues.enumerated() {
            group.enter()
            DispatchQueue.global(qos: qos).async {
                // Each thread uses the same valid envId – concurrent calls on the same instance
                Flagship.sharedInstance.start(envId: self.validEnvId, apiKey: "bg_test_key")
                group.leave()
            }
        }

        let result = group.wait(timeout: .now() + 10)
        XCTAssertEqual(result, .success,
                       "Concurrent start() calls from multiple background threads caused a deadlock or timeout")
        XCTAssertEqual(Flagship.sharedInstance.currentStatus, .SDK_INITIALIZED,
                       "SDK must be in SDK_INITIALIZED state after concurrent starts")
    }

    // 5. Status change callback must fire correctly when start() is called from a background thread
    func testStatusCallbackFiredFromBackgroundThreadStart() {
        let exp = expectation(description: "onSdkStatusChanged callback received")

        let config = FSConfigBuilder()
            .withOnSdkStatusChanged { status in
                if status == .SDK_INITIALIZED {
                    exp.fulfill()
                }
            }
            .build()

        DispatchQueue.global(qos: .background).async {
            Flagship.sharedInstance.start(envId: self.validEnvId, apiKey: "bg_test_key", config: config)
        }

        waitForExpectations(timeout: 5)
    }
}
