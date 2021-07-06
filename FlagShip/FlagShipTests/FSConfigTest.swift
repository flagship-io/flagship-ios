//
//  FSConfigTest.swift
//  FlagshipTests
//
//  Created by Adel on 25/08/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSConfigTest: XCTestCase {

    override func setUpWithError() throws {

     }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testInitConfig() {

       let config =  FSConfig(.BUCKETING, timeout: 0.1)
        XCTAssert(config.mode == .BUCKETING)
        XCTAssert(config.flagshipTimeOutRequestApi == 0.1)
    }

    func testInitWithDefault() {

        let config =  FSConfig()
        XCTAssert(config.mode == .DECISION_API)
        XCTAssert(config.flagshipTimeOutRequestApi == FS_TimeOutRequestApi)

    }

    func testInitWithZeroValue() {

        let config =  FSConfig(.DECISION_API, timeout: 0)
        XCTAssert(config.mode == .DECISION_API)
        XCTAssert(config.flagshipTimeOutRequestApi == FS_TimeOutRequestApi)

    }

    func testInitWithNValue() {

        let config =  FSConfig(.DECISION_API, timeout: -1)
        XCTAssert(config.mode == .DECISION_API)
        XCTAssert(config.flagshipTimeOutRequestApi == FS_TimeOutRequestApi)

    }

}
