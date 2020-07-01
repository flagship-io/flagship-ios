//
//  FlagshipTestWithMockedData.swift
//  FlagshipTests
//
//  Created by Adel on 29/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship


class FlagshipTestWithMockedData: XCTestCase {

     var flagShipMock:FlagshipMock!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        flagShipMock = FlagshipMock()
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
    
    
    
    
    func testStartMock(){
        
        let expectation = self.expectation(description: #function)
        flagShipMock.startMock(environmentId: "bkk9glocmjcg0vtmdlng", "alias", .BUCKETING) { (result) in

            XCTAssert(result == .Ready)
            
            Flagship.sharedInstance.activateModification(key: "ctxKeyString")
            
            Flagship.sharedInstance.activateModification(key: "key1")

            
            let result = Flagship.sharedInstance.getModificationInfo("ctxKeyString")
            
            XCTAssert(result is [String:String]? || result == nil)

            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
     }
    
    
    

}
