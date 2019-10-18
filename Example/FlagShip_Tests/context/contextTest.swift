//
//  contextTest.swift
//  FlagShip_Tests
//
//  Created by Adel on 16/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import FlagShip

class contextTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        ABFlagShip.sharedInstance.startFlagShip("alice") { (state) in
            
            print("Ready to use#####################")
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
    
    
    
    func testContext(){
        
        ABFlagShip.sharedInstance.context("toto", true)
        
        
    }

}
