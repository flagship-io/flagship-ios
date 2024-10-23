//
//  FSFlagTest.swift
//  FlagshipTests
//
//  Created by Adel on 03/03/2022.
//

import XCTest

@testable import Flagship

class FSFlagTest: XCTestCase {
    var testVisitor: FSVisitor?
    var urlFakeSession: URLSession?
    
    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        // let urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        /// Start sdk
        let fsConfig = FSConfigBuilder().DecisionApi().build()

        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdov", apiKey: "apiKey", config: fsConfig)
        
        do {
            guard let path = Bundle(for: type(of: self)).url(forResource: "decisionApi", withExtension: "json") else { return }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            
            MockURLProtocol.requestHandler = { _ in
                
                let response = HTTPURLResponse(url: URL(string: "ok")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
        } catch {
            print("---------------- Failed to load the mock api file ----------")
        }
        
        // Create Visitor
        testVisitor = Flagship.sharedInstance.newVisitor(visitorId: "alias", hasConsented: true).build()
        // Check if the flagsync is Created
       // XCTAssertTrue(testVisitor?.flagSyncStatus == .CREATED)
        // Chekc the fetch status / reason
        XCTAssertTrue(testVisitor?.fetchStatus == .FETCH_REQUIRED)
        XCTAssertTrue(testVisitor?.requiredFetchReason == .FLAGS_NEVER_FETCHED || testVisitor?.requiredFetchReason == .FLAGS_FETCHED_FROM_CACHE)

        // Set fake session
        if let aUrlFakeSession = urlFakeSession {
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
    }
    
    func testGetflag() {
        let expectationSync = XCTestExpectation(description: "Service-GetScript")

        testVisitor?.fetchFlags(onFetchCompleted: {
            /// Check if flagSync is fetched
         //   XCTAssertTrue(self.testVisitor?.flagSyncStatus == .FLAGS_FETCHED)
            
            // Chekc the fetch status // reason
            XCTAssertTrue(self.testVisitor?.fetchStatus == .FETCHED)
            XCTAssertTrue(self.testVisitor?.requiredFetchReason == .NONE)

            if let flag = self.testVisitor?.getFlag(key: "btnTitle") {
                XCTAssertTrue(flag.value(defaultValue: "dfl") == "Alpha_demoApp")
                XCTAssertTrue(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "bvcdqksmicqghldq9agg")
                XCTAssertTrue(flag.metadata().variationId == "bvcdqksmicqghldq9aig")
                XCTAssertTrue(flag.metadata().variationGroupId == "bvcdqksmicqghldq9ahg")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "cmapForTest")
                XCTAssertTrue(flag.metadata().campaignName == "campaign_name")
                XCTAssertTrue(flag.metadata().variationGroupName == "varGroup_name")
                XCTAssertTrue(flag.metadata().variationName == "variation_name")
                XCTAssertTrue(flag.status == .FETCHED)
            }
            
            if let flagBis = self.testVisitor?.getFlag(key: "---") {
                XCTAssertFalse(flagBis.exists())
                XCTAssertTrue(flagBis.metadata().campaignId == "")
            }
            
            /// Test with bad type
            if let flag = self.testVisitor?.getFlag(key: "btnTitle") {
                XCTAssertTrue(flag.value(defaultValue: 111) == 111)
                XCTAssertTrue(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "bvcdqksmicqghldq9agg")
                XCTAssertTrue(flag.metadata().variationId == "bvcdqksmicqghldq9aig")
                XCTAssertTrue(flag.metadata().variationGroupId == "bvcdqksmicqghldq9ahg")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "cmapForTest")
            }
            
            /// Test with nil default value
            var nilValue: String?
            if let flag = self.testVisitor?.getFlag(key: "btnTitle") {
                XCTAssertTrue(flag.value(defaultValue: "nilValue") == "Alpha_demoApp")
                XCTAssertTrue(flag.exists())
                XCTAssertTrue(flag.metadata().variationName == "variation_name")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "cmapForTest")
                XCTAssertTrue(flag.metadata().campaignName == "campaign_name")
                XCTAssertTrue(flag.metadata().campaignId == "bvcdqksmicqghldq9agg")
                XCTAssertTrue(flag.metadata().variationId == "bvcdqksmicqghldq9aig")
                XCTAssertTrue(flag.metadata().variationGroupId == "bvcdqksmicqghldq9ahg")
                XCTAssertTrue(flag.metadata().variationGroupName == "varGroup_name")
            }
            
            // Change the context and chekc the status
            self.testVisitor?.updateContext("newKey", "val") // the state should be changed
            
            if let flag = self.testVisitor?.getFlag(key: "btnTitle") {
                XCTAssertTrue(flag.status == .FETCH_REQUIRED)
            }
            // check wwith not foud one
            if let flagNotfound = self.testVisitor?.getFlag(key: "notFound") {
                XCTAssertTrue(flagNotfound.status == .NOT_FOUND)
            }
            expectationSync.fulfill()
        })
        
        wait(for: [expectationSync], timeout: 5.0)
    }
        
    func testMetadata() {
        XCTAssertTrue(FSFlagMetadata(nil).variationGroupId == "")
        XCTAssertTrue(FSFlagMetadata(nil).variationId == "")
        XCTAssertTrue(FSFlagMetadata(nil).campaignId == "")
        XCTAssertTrue(FSFlagMetadata(nil).campaignType == "")
        XCTAssertTrue(FSFlagMetadata(nil).slug == "")
    }
    
//    func testFlagSyncStatus() {
//        let syncUser = Flagship.sharedInstance.newVisitor(visitorId: "userSync", hasConsented: true, instanceType: .NEW_INSTANCE).build()
//        XCTAssertTrue(syncUser.flagSyncStatus == .CREATED)
//        // Update context
//        syncUser.updateContext(["keySync": "valSync"])
//        XCTAssertTrue(syncUser.flagSyncStatus == .CONTEXT_UPDATED)
//        // Autenticate
//        syncUser.authenticate(visitorId: "syncUser")
//        XCTAssertTrue(syncUser.flagSyncStatus == .AUTHENTICATED)
//        // Unauthenticate
//        syncUser.unauthenticate()
//        XCTAssertTrue(syncUser.flagSyncStatus == .UNAUTHENTICATED)
//    }
    
    func testGetFlagOnPanic() {
        let expectationSync = XCTestExpectation(description: "Service-GetScript")
        do {
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "decisionApiPanic", withExtension: "json") else { return }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            
            MockURLProtocol.requestHandler = { _ in
                
                let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
        } catch {
            print("---------------- Failed to load the mock api file ----------")
        }
        
        testVisitor?.fetchFlags {
            XCTAssertTrue(Flagship.sharedInstance.currentStatus == .SDK_PANIC)
            
            if let flag = self.testVisitor?.getFlag(key: "btnTitle") {
                XCTAssertTrue(flag.value(defaultValue: "defaultValue") == "defaultValue")
                XCTAssertFalse(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "")
                XCTAssertTrue(flag.metadata().variationId == "")
                XCTAssertTrue(flag.metadata().variationGroupId == "")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "")
                XCTAssertTrue(flag.status == .PANIC)

                // Test
                self.testVisitor?.updateContext(["k1": "V1"])
                if let ctx = self.testVisitor?.getContext() {
                    XCTAssertFalse(ctx.keys.contains("k1"))
                }
                
                /// Test others call for the panic mode
                self.testVisitor?.authenticate(visitorId: "vid")
                self.testVisitor?.unauthenticate()
        
                self.testVisitor?.strategy?.getStrategy().cacheVisitor()
                self.testVisitor?.strategy?.getStrategy().lookupHits()
                self.testVisitor?.strategy?.getStrategy().lookupVisitor()
                XCTAssertNil(self.testVisitor?.strategy?.getStrategy().getFlagModification("key"))
                XCTAssertTrue(self.testVisitor?.strategy?.getStrategy().getModification("key", defaultValue: "dflt") == "dflt")
                XCTAssertNil(self.testVisitor?.strategy?.getStrategy().getFlagModification("key"))
            }
            expectationSync.fulfill()
        }
        
        wait(for: [expectationSync], timeout: 5.0)
    }
}
