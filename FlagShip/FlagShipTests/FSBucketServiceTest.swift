//
//  FSBucketServiceTest.swift
//  FlagshipTests
//
//  Created by Adel on 31/07/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship


class FSBucketServiceTest: XCTestCase {
    
    
    var serviceBucket:ABService!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        serviceBucket = ABService("bkk9glocmjcg0vtmdlo0", "userId", "")
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
    
    
    
    
    func testGetScript(){
        /// remove last modified date, to avoid 304
         UserDefaults.standard.removeObject(forKey: FSLastModified_Key)
        
        let expectation = self.expectation(description: #function)
        
        serviceBucket.getFSScript { (bucketObject, result) in
            
            
               expectation.fulfill()
            
        }
        waitForExpectations(timeout: 10)
        
    }

}
