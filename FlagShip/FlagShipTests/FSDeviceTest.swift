//
//  FSDeviceTest.swift
//  FlagshipTests
//
//  Created by Adel on 01/09/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSDeviceTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testGetDeviceLanguage() {

        XCTAssertTrue(NSLocale.current.languageCode == FSDevice.getDeviceLanguage() )
    }

    func testGetDeviceType() {

       XCTAssertTrue("Mobile" == FSDevice.getDeviceType()  ||  "Tablet" == FSDevice.getDeviceType()  )
    }

    func testIsFirstTimeUser() {

        UserDefaults.standard.removeObject(forKey: "sdk_firstTimeUser")

        XCTAssertTrue(FSDevice.isFirstTimeUser())

        XCTAssertFalse(FSDevice.isFirstTimeUser())

    }

    func testValidateIpAddress() {

        // 2001:0db8:0a0b:12f0:0000:0000:0000:0001

        XCTAssertTrue(FSDevice.validateIpAddress(ipToValidate: "684D:1111:222:3333:4444:5555:6:77"))

        XCTAssertTrue(FSDevice.validateIpAddress(ipToValidate: "19.117.63.126"))

        XCTAssertFalse(FSDevice.validateIpAddress(ipToValidate: "684D:1111:222:3333:4444:5555:6:77:4"))

        XCTAssertFalse(FSDevice.validateIpAddress(ipToValidate: "319.117.63.126"))

    }
}
