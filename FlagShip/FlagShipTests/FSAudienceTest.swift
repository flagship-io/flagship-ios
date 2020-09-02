//
//  FSAudienceTest.swift
//  FlagshipTests
//
//  Created by Adel on 27/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest

@testable import Flagship

class FSAudienceTest: XCTestCase {

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
 
    
    func testchekValidity(){
        
      
        
        for itemPresetContext in PresetContext.allCases{
            
            XCTAssert(itemPresetContext.chekcValidity("valueToSet") is Bool)
        }
    }

}
