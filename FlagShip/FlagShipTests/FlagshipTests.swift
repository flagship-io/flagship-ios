//
//  FlagshipTests.swift
//  FlagshipTests
//
//  Created by Adel on 19/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FlagshipTests: XCTestCase {
    
      var fsCacheMgr:FSCacheManager!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        UserDefaults.standard.removeObject(forKey: FSLastModified_Key)
        fsCacheMgr = FSCacheManager()


        
    }

    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        guard let resultUrl = fsCacheMgr.createUrlForCache() else { return  }
        do {
            try FileManager.default.removeItem(at: resultUrl)
        }catch{
            
        }
         let resultUrlBis = fsCacheMgr.createUrlForCache()
        XCTAssertTrue(resultUrlBis?.absoluteString.count != 0)
    }
 

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    /// Test start Flagship
    func testStartFlagshipWithBadEnvId(){

        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(environmentId: "", "", .BUCKETING) { (result) in
            
            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
       
    }
    
    
    func testStartFlagshipwithEmptyUserID(){

        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(environmentId: "bkk9glocmjcg0vtmdlng", "", .BUCKETING) { (result) in
            
            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)
       
    }
    
    

    func testStartFlagship(){
        
        
        Flagship.sharedInstance.activateModification(key: "")

        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(environmentId: "bkk9glocmjcg0vtmdlng", nil, .BUCKETING) { (result) in

            XCTAssert(result == .Ready)
            
            
            Flagship.sharedInstance.getCampaigns { (state) in
                
                expectation.fulfill()
                
            }
            
        }
        waitForExpectations(timeout: 10)
        

    }
    
    
    func testStartFlagshiWithApac(){

        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(environmentId: "bkk9glocmjcg0vtmdlng", nil, .BUCKETING, apacRegion:FSRegion("1212121212121##1#1#1#1;")) { (result) in

            XCTAssert(result == .Ready)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)

    }
    
    

    
    
    /// Deprecated start
    
    func testDeprecatedStart(){
        
        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.startFlagShip(environmentId: "bkk9glocmjcg0vtmdlng", "alias") { (result) in
            
            XCTAssert(result == .Ready)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)

    }
}
