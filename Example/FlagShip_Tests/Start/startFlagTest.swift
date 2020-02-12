//
//  startFlagTest.swift
//  FlagShip_Tests
//
//  Created by Adel on 16/10/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import FlagShip
class startFlagTest: XCTestCase {

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
    
    // Start
    
    
    func testStartFlagShipWithNil(){
        
        ABFlagShip.sharedInstance.startFlagShip(nil) { (state) in
            
            print(state)
            
        }
        
        
        func testContext(){
              
              ABFlagShip.sharedInstance.context("toto", true)
          }

    }
    
    
    
    
    func testStartFlagShipWithIdEMpty(){
        
        ABFlagShip.sharedInstance.startFlagShip("") { (state) in
            
        }
    }
    
    
    func testStartFlagShipWithId(){
         
         ABFlagShip.sharedInstance.startFlagShip("alice") { (state) in
             
         }
     }
    
    
    func testupdateContext(){
        
        ABFlagShip.sharedInstance.updateContext(["key":true]) { (state) in
            
        }
    }
    

}
