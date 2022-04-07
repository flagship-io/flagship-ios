//
//  FsToolsTest.swift
//  FlagshipTests
//
//  Created by Adel on 27/08/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FsToolsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testchekcXidEnvironment() {

        XCTAssertFalse(FSTools.chekcXidEnvironment(""))

        XCTAssertTrue(FSTools.chekcXidEnvironment("bkk9glocmjcg0vtmdabc"))
    }

    func testManageVisitorId() {

        do {

            let ret = try FSTools.manageVisitorId("visitorId")

            XCTAssertEqual(ret, "visitorId")

            let retBis = try FSTools.manageVisitorId(nil)

            XCTAssertTrue(retBis.count > 0)

            UserDefaults.standard.removeObject(forKey: FlagShipIdKey)

            let retTer = try FSTools.manageVisitorId(nil)

            XCTAssertTrue(retTer.count > 0)

            // Try with empty file
            try FSTools.manageVisitorId("")

        } catch {

        }

    }

}
