//
//  FSGeneratorTest.swift
//  FlagshipTests
//
//  Created by Adel on 01/04/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSGeneratorTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    
    
    func testGenerateId(){
        
        
        XCTAssertNotNil(FSGenerator.generateFlagShipId)
    }
    
    
    
    func testSaveGet(){
        
        /// set the id
        FSGenerator.saveFlagShipIdInCache(userId: "id123")
        
        /// Check the id read from cache
        XCTAssertTrue(FSGenerator.getFlagShipIdInCache() == "id123")
    }
    
    
    
    func testReset(){
        
         FSGenerator.resetFlagShipIdInCache()
    }
    
    
    func testManageVisitor(){
        
        
        do {
            
            let idVisitor = try FSTools.manageVisitorId(nil)
            
            XCTAssert(idVisitor.count != 0)
            
            let idVisitorBis = try FSTools.manageVisitorId("abcdef")
            
              XCTAssert(idVisitorBis.count != 0)

            
        }catch{
            
            
        }
        
    }

}
