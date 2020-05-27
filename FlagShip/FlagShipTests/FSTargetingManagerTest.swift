//
//  FSTargetingManagerTest.swift
//  FlagshipTests
//
//  Created by Adel on 28/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSTargetingManagerTest: XCTestCase {
    
    
    var targetingManager:FSTargetingManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
         targetingManager = FSTargetingManager()
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testisTargetingGroupIsOkay(){
        /// test with nil entry
         XCTAssertFalse(targetingManager.isTargetingGroupIsOkay(nil))
    }
    
    
    ///     func checkCondition(_ cuurentValue:Any, _ operation:FSoperator, _ audienceValue:Any)->Bool{

    func testCheckCondition(){
        
        XCTAssertTrue(targetingManager.checkCondition(12, .EQUAL, 12))
        XCTAssertFalse(targetingManager.checkCondition(12, .EQUAL, 121))

        
        XCTAssertTrue(targetingManager.checkCondition("aaaa", .EQUAL, "aaaa"))
        XCTAssertFalse(targetingManager.checkCondition("aaaa", .EQUAL, "aaaav"))


    }

}
