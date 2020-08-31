//
//  FSStorageTest.swift
//  FlagshipTests
//
//  Created by Adel on 29/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSStorageTest: XCTestCase {
    
    
    var storage:FSStorage!

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
    
    
   
    
    func testRetreive(){

        /// Set File
        FSStorage.store(FSBucketCache("iduser"), to: .documents, as: "iduser")
        
        /// Retreive existing file
        let result = FSStorage.retrieve("iduser", from: .documents, as:FSBucketCache.self)
        
        XCTAssertEqual(result?.visitorId , "iduser")
        
        
        /// File not existing
        
        let resultBis = FSStorage.retrieve("iduserBis", from: .documents, as:FSBucketCache.self)
        
        XCTAssertTrue(resultBis == nil)
        
        
        //// Bad data
        FSStorage.store(Data(), to: .documents, as: "iduserTer")

        let resultTer = FSStorage.retrieve("iduserTer", from: .documents, as:FSBucketCache.self)
        
        XCTAssertTrue(resultTer == nil)
         
    }

}
