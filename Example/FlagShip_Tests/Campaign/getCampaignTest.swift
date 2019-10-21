//
//  getCampaignTest.swift
//  FlagShip_Tests
//
//  Created by Adel on 16/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import FlagShip

class getCampaignTest: XCTestCase {

    override func setUp() {
        
        ABFlagShip.sharedInstance.startFlagShip("alice") { (state) in
            
            
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            
        }
    }
    
    
    func testGetCampaign(){
        
        // Create an expectation
        let expectation = self.expectation(description: "getCampaign")
        
        ABFlagShip.sharedInstance.getCampaigns { (error) in
            
            print(error.debugDescription)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout:10, handler: nil)
    }
    
    
    
    func testGetCampaignWithNoContext(){
        
        // Create an expectation
        let expectation = self.expectation(description: "getCampaign")
        
        ABFlagShip.sharedInstance.getCampaigns { (error) in
            
            print(error.debugDescription)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout:10, handler: nil)
    }

}
