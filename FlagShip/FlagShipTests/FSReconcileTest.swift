//
//  ReconcileTest.swift
//  FlagshipTests
//
//  Created by Adel on 20/12/2021.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class ReconcileTest: XCTestCase {

 
    let expectation = XCTestExpectation(description: "Flagship-Config")
    override func setUpWithError() throws {
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlrr", apiKey: "apikey")

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTupleAuthentication() {
        
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "ABCD-EFGH",hasConsented: true).build()
        
        XCTAssert(v1.visitorId == "ABCD-EFGH")
        XCTAssert(v1.anonymousId == nil)
        
        /// Check the service
        XCTAssert(v1.configManager.decisionManager?.networkService.visitorId == "ABCD-EFGH")
        XCTAssert(v1.configManager.decisionManager?.networkService.anonymousId == nil)
        
        /// Set Authenticate
        v1.authenticate(visitorId: "Alex")
        XCTAssert(v1.visitorId         == "Alex")
        XCTAssert(v1.anonymousId       == "ABCD-EFGH")
        
        let flag = v1.getFlag(key: "keyFalg")
        XCTAssert(v1.requiredFetchReason == .VISITOR_AUTHENTICATED)
        XCTAssert(flag.status == .NOT_FOUND)
        
        /// Check the service
        XCTAssert(v1.configManager.decisionManager?.networkService.visitorId == "Alex")
        XCTAssert(v1.configManager.decisionManager?.networkService.anonymousId == "ABCD-EFGH")
        
        /// Set unAuthenticate
        v1.unauthenticate()
        XCTAssert(v1.visitorId == "ABCD-EFGH")
        XCTAssert(v1.anonymousId == nil)
        
        let flagBis = v1.getFlag(key: "keyFalg")
        XCTAssert(v1.requiredFetchReason == .VISITOR_UNAUTHENTICATED)
        XCTAssert(flagBis.status == .NOT_FOUND)
        
        /// Check the service
        XCTAssert(v1.configManager.decisionManager?.networkService.visitorId == "ABCD-EFGH")
        XCTAssert(v1.configManager.decisionManager?.networkService.anonymousId == nil)


    }

    func testTupleAuthenticationWithLoggedSessionAtSatrt() {
        
        /// Save the generated on in cache to use in test
        FSGenerator.saveFlagShipIdInCache(userId: "id123")
        /// Create visitor
        let v2 = Flagship.sharedInstance.newVisitor(visitorId: "Alex",hasConsented: true).isAuthenticated(true).build()
        
        XCTAssert(v2.visitorId == "Alex")
        XCTAssert(v2.anonymousId == "id123" )
        
        /// Check the service
        XCTAssert(v2.configManager.decisionManager?.networkService.visitorId == "Alex")
        XCTAssert(v2.configManager.decisionManager?.networkService.anonymousId == "id123")

        /// Set authenticate
        v2.authenticate(visitorId: "Alex")
        XCTAssert(v2.visitorId == "Alex")
        XCTAssert(v2.anonymousId == "id123" )
        
        /// Check the service
        XCTAssert(v2.configManager.decisionManager?.networkService.visitorId == "Alex")
        XCTAssert(v2.configManager.decisionManager?.networkService.anonymousId == "id123")

        /// Set unAuthenticate
        v2.unauthenticate()
        XCTAssert(v2.visitorId == "id123")
        XCTAssert(v2.anonymousId == nil)
        
        /// Check the service
        XCTAssert(v2.configManager.decisionManager?.networkService.visitorId == "id123")
        XCTAssert(v2.configManager.decisionManager?.networkService.anonymousId == nil)
    }
    
}
