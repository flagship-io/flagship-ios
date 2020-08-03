//
//  FSServiceTest.swift
//  FlagshipTests
//
//  Created by Adel on 19/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSServiceTest: XCTestCase {
    

    var serviceTest:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey")
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
 
    
    
    func testActivate(){
        
        serviceTest.activateCampaignRelativetoKey("key", FSCampaigns("idCamp"))
    }
    
    
    func testsendkeyValueContext(){
     
        serviceTest.sendkeyValueContext(["key1":"", "":true, "key2":12, "key3":["key1":"", "":true, "key2":12]])
    }
    
    
    func testSendTracking(){
        
        let expectation = self.expectation(description: #function)

        serviceTest.sendTracking(FSEvent(eventCategory: .Action_Tracking, eventAction: "act"))
        
        expectation.fulfill()
              
        waitForExpectations(timeout: 2)
    }
    
    
    //// Get Campaign
    func testGetCampaign(){
        
        let expectation = self.expectation(description: #function)
        
        serviceTest.getCampaigns([:]) { (camp, error) in
            
            expectation.fulfill()
            
        }
        
         waitForExpectations(timeout: 2)
    }
    
}
