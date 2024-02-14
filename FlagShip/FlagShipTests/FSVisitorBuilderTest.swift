//
//  FSVisitorBuilderTest.swift
//  FlagshipTests
//
//  Created by Adel on 09/12/2021.
//

import XCTest
@testable import Flagship

class FSVisitorBuilderTest: XCTestCase {

    override func setUpWithError() throws {
        /// Start flagship
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apikey")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuilder(){
        
        Flagship.sharedInstance.reset()
        let visitorToTest = Flagship.sharedInstance.newVisitor(visitorId: "vistorTest", hasConsented: true).build()
        /// Check the consent if true by default
        XCTAssertTrue(visitorToTest.hasConsented == true)
        XCTAssertTrue(visitorToTest.visitorId == "vistorTest")
        
        /// create another visitor
        Flagship.sharedInstance.reset()
        let visitorToTestBis = Flagship.sharedInstance.newVisitor(visitorId: "vistorTestBis",hasConsented: false, instanceType: .NEW_INSTANCE).build()
        XCTAssertTrue(visitorToTestBis.hasConsented == false)
        XCTAssertTrue(visitorToTestBis.visitorId == "vistorTestBis")
        XCTAssertNil(Flagship.sharedInstance.sharedVisitor)


    }

}
