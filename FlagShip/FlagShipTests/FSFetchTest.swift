//
//  FSFetchTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 24/10/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

final class FSFetchTest: XCTestCase {
    
    var urlFakeSession: URLSession?
    
    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdov", apiKey: "apiKey")
        do {
            guard let path = Bundle(for: type(of: self)).url(forResource: "decisionApi", withExtension: "json") else { return }
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            MockURLProtocol.requestHandler = { _ in
                let response = HTTPURLResponse(url: URL(string: "ok")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
        } catch {
            print("-------------- Error ----------")
        }
    }
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

   

    func testFetchFailed() {
        let expecAllFlag = XCTestExpectation(description: "Error on fetch")
        
        // Create Visitor
        let user: FSVisitor = Flagship.sharedInstance.newVisitor(visitorId: "user", hasConsented: true).build()
        // Set fake session
        if let aUrlFakeSession = urlFakeSession {
            user.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        // FetchFlags
        user.fetchFlags {
            XCTAssert(user.requiredFetchReason == .FLAGS_FETCHING_ERROR)
            XCTAssert(user.fetchStatus == .FETCH_REQUIRED)
            expecAllFlag.fulfill()
        }
        wait(for: [expecAllFlag], timeout: 5.0)
    }
    

}
