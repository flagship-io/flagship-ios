//
//  FlagshipTestWithPanic.swift
//  FlagshipTests
//
//  Created by Adel on 09/09/2021.
//  Copyright © 2021 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FlagshipTestWithPanic: XCTestCase {

    var serviceTest: ABService!
    let mockUrl = URL(string: "Mock")!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceTest = ABService("idClient", "isVisitor", "aid1", "apiKey")

        /// Set our mock session into service
        serviceTest.sessionService = sessionTest

        Flagship.sharedInstance.service = serviceTest
        
        let testBundle = Bundle(for: type(of: self))

        guard let path = testBundle.url(forResource: "decisionApiPanic", withExtension: "json") else { return  }

        let data = try Data(contentsOf: path, options: .alwaysMapped)
        

        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testonStartDecisionApiWithSucess(){

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-API-panic")

        do {

            // Set visitor id
            Flagship.sharedInstance.setVisitorId("202072017183814142")
            // set context
            Flagship.sharedInstance.updateContext(ALL_USERS, "")

            Flagship.sharedInstance.onStartDecisionApi { (result) in
                
                XCTAssertTrue(result == .Disabled)
                /// Rollbakc the dissabled
                Flagship.sharedInstance.disabledSdk = false
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testonStartBucketingWithSucess(){

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-API-panic")

            // Set visitor id
            Flagship.sharedInstance.setVisitorId("202072017183814142")
            // set context
            Flagship.sharedInstance.updateContext(ALL_USERS, "")

            Flagship.sharedInstance.onStartBucketing { (result) in
                
                XCTAssertTrue(result == .Disabled)
                /// Rollbakc the dissabled
                Flagship.sharedInstance.disabledSdk = false

                
                expectation.fulfill()
            }
        
        wait(for: [expectation], timeout: 5.0)

    }

    

}
