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
    
    var serviceTest:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey")
    let mockUrl = URL(string: "BucketMock")!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceBucket = ABService("idClient", "isVisitor", "apiKey")
        
        /// Set our mock session into service
        serviceBucket.sessionService = sessionTest
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
    
    //// Get Campaign
    func testGetScriptWithSucess(){
        
        /// Create the mock response
        /// Load the data
        
        let expectation = XCTestExpectation(description: "Service-GetScript")
        
        do {
            
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            
            MockURLProtocol.requestHandler = { request in
                
                let response = HTTPURLResponse(url:self.mockUrl , statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
            
            serviceBucket.getFSScript { (bucketObject, error) in
                
                if let bucket = bucketObject {
                    
                    XCTAssertFalse(bucket.panic)
                    XCTAssert(bucket.campaigns.count == 4)
                    XCTAssert(error == nil)
                    
                    for itemCamp in bucket.campaigns{
                        
                        XCTAssert((itemCamp.idCampaign == "bqso7p5tl9jg05d80320") ||
                                 (itemCamp.idCampaign == "br6h35n811lg0788np8g")  ||
                                 (itemCamp.idCampaign == "br6h4dv811lg07g61g00")  ||
                                 (itemCamp.idCampaign == "br8dca47pe0g1648p34g")  )
                        
                        XCTAssertTrue(itemCamp.variationGroups.count == 1  || itemCamp.variationGroups.count == 2)
                    }
                    
                    expectation.fulfill()
                }
                
            }
            
        }catch{
            
            print("error")
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testGetScriptWithBadParsing(){
        
        /// Create the mock response
        /// Load the data
        
        let expectation = XCTestExpectation(description: "Service-GetScript")
        
        
        let data = Data()
        
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(url:self.mockUrl , statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        
        serviceBucket.getFSScript { (bucketObject, error) in
            
            XCTAssert(error == FlagshipError.CetScriptError)
            expectation.fulfill()
        }
        
        
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    
    func testGetScriptWithFailed(){
        
        /// Create the mock response
        /// Load the data
        
        let expectation = XCTestExpectation(description: "Service-GetScript")
        
        
        let data = Data()
        
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(url:self.mockUrl , statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        
        serviceBucket.getFSScript { (bucketObject, error) in
            
            XCTAssert(error == FlagshipError.CetScriptError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testGetScriptNotModified(){
        
        /// Create the mock response
        /// Load the data
        
        let expectation = XCTestExpectation(description: "Service-GetScript")
        
        
        let data = Data()
        
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(url:self.mockUrl , statusCode: 304, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        
        serviceBucket.getFSScript { (bucketObject, error) in
            
            XCTAssert(error == FlagshipError.ScriptNotModified)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
