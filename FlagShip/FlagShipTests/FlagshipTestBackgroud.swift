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

    override func setUpWithError() throws {
        Flagship.sharedInstance.start(envId: "bg_test_env", apiKey: "bg_test_key")
        Thread.sleep(forTimeInterval: 1.0)
    }

    override func tearDownWithError() throws {
        Flagship.sharedInstance.close()
        Thread.sleep(forTimeInterval: 0.5)
    }

    // 1. sharedInstance + currentConfig must be reachable from a background thread
    func testSharedInstanceAndConfigFromBackgroundThread() {
        let exp = expectation(description: "background access")
        DispatchQueue.global(qos: .background).async {
            let config = Flagship.sharedInstance.currentConfig
            XCTAssertNotNil(config)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    // 2. LogManager must not crash when called from a background thread
    func testLogManagerSafeFromBackgroundThread() {
        let exp = expectation(description: "log from background")
        DispatchQueue.global(qos: .background).async {
            FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE,
                                   messageToDisplay: FSLogMessage.MESSAGE("background log test"))
            exp.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    // 3. Concurrent access from multiple threads must not deadlock or crash
    func testConcurrentSharedInstanceAccess() {
        let group = DispatchGroup()
        for i in 0..<10 {
            group.enter()
            DispatchQueue.global(qos: i % 2 == 0 ? .background : .userInitiated).async {
                _ = Flagship.sharedInstance.currentConfig
                FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE,
                                       messageToDisplay: FSLogMessage.MESSAGE("thread \(i)"))
                group.leave()
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 10), .success, "Possible deadlock on concurrent access")
    }
}
