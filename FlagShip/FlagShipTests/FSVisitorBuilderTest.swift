//
//  FSVisitorBuilderTest.swift
//  FlagshipTests
//
//  Created by Adel on 09/12/2021.
//

@testable import Flagship
import XCTest

class FSVisitorBuilderTest: XCTestCase {
    override func setUpWithError() throws {
        /// Start flagship
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apikey")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuilder() {
        Flagship.sharedInstance.reset()
        let visitorToTest = Flagship.sharedInstance.newVisitor(visitorId: "vistorTest", hasConsented: true).withFetchFlagsStatus { _, _ in

        }.build()
        /// Check the consent if true by default
        XCTAssertTrue(visitorToTest.hasConsented == true)
        XCTAssertTrue(visitorToTest.visitorId == "vistorTest")
        XCTAssertTrue(visitorToTest._onFetchStatusChanged != nil)

        /// create another visitor
        Flagship.sharedInstance.reset()
        let visitorToTestBis = Flagship.sharedInstance.newVisitor(visitorId: "vistorTestBis", hasConsented: false, instanceType: .NEW_INSTANCE).build()
        XCTAssertTrue(visitorToTestBis.hasConsented == false)
        XCTAssertTrue(visitorToTestBis.visitorId == "vistorTestBis")
        XCTAssertNil(Flagship.sharedInstance.sharedVisitor)
        XCTAssertNil(visitorToTestBis._onFetchStatusChanged)

        visitorToTestBis._onFetchStatusChanged?(.FETCHED, .AUTHENTICATE)
    }

    func testBuilderWithCallBack() {
        Flagship.sharedInstance.reset()
        let visitorCallback = Flagship.sharedInstance.newVisitor(visitorId: "vistorTestCallback", hasConsented: true).withFetchFlagsStatus { f, r in

            XCTAssertTrue(f == .FETCHING)
            XCTAssertTrue(r == .AUTHENTICATE)
        }.build()

        visitorCallback._onFetchStatusChanged?(.FETCHING, .AUTHENTICATE)
    }
}
