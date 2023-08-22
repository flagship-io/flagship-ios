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

        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey", config: fsConfig)
        
        do {
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            
            MockURLProtocol.requestHandler = { _ in
                
                let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
        } catch {
            print("---------------- Failed to load the mock api file ----------")
        }
        
        /// Create new visitor
        testVisitor = Flagship.sharedInstance.newVisitor("alias").build()
        // Check if the flagsync is Created
        XCTAssertTrue(testVisitor?.flagSyncStatus == .CREATED)
        /// Set fake session
        if let aUrlFakeSession = urlFakeSession {
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
    }
    
    func testGetflag() {
        let expectationSync = XCTestExpectation(description: "Service-GetScript")

        testVisitor?.fetchFlags(onFetchCompleted: {
            /// Check if flagSync is fetched
            XCTAssertTrue(self.testVisitor?.flagSyncStatus == .FLAGS_FETCHED)
            if let flag = self.testVisitor?.getFlag(key: "btnTitle", defaultValue: "dfl") {
                XCTAssertTrue(flag.value() as! String == "Alpha_demoApp")
                XCTAssertTrue(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "bvcdqksmicqghldq9agg")
                XCTAssertTrue(flag.metadata().variationId == "bvcdqksmicqghldq9aig")
                XCTAssertTrue(flag.metadata().variationGroupId == "bvcdqksmicqghldq9ahg")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "cmapForTest")
            }
            
            if let flagBis = self.testVisitor?.getFlag(key: "---", defaultValue: "dfl") {
                XCTAssertFalse(flagBis.exists())
                XCTAssertTrue(flagBis.metadata().campaignId == "")
            }
            
            /// Test with bad type
            if let flag = self.testVisitor?.getFlag(key: "btnTitle", defaultValue: 111) {
                XCTAssertTrue(flag.value() as? Int == 111)
                XCTAssertTrue(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "")
                XCTAssertTrue(flag.metadata().variationId == "")
                XCTAssertTrue(flag.metadata().variationGroupId == "")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "")
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
    
    func testFlagSyncStatus() {
        let syncUser = Flagship.sharedInstance.newVisitor("userSync", instanceType: .NEW_INSTANCE).build()
        XCTAssertTrue(syncUser.flagSyncStatus == .CREATED)
        // Update context
        syncUser.updateContext(["keySync": "valSync"])
        XCTAssertTrue(syncUser.flagSyncStatus == .CONTEXT_UPDATED)
        // Autenticate
        syncUser.authenticate(visitorId: "syncUser")
        XCTAssertTrue(syncUser.flagSyncStatus == .AUTHENTICATED)
        // Unauthenticate
        syncUser.unauthenticate()
        XCTAssertTrue(syncUser.flagSyncStatus == .UNAUTHENTICATED)
    }
    
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
            XCTAssertTrue(Flagship.sharedInstance.currentStatus == .PANIC_ON)
            
            if let flag = self.testVisitor?.getFlag(key: "btnTitle", defaultValue: "defaultValue") {
                XCTAssertTrue(flag.value() as? String == "defaultValue")
                XCTAssertFalse(flag.exists())
                XCTAssertTrue(flag.metadata().campaignId == "")
                XCTAssertTrue(flag.metadata().variationId == "")
                XCTAssertTrue(flag.metadata().variationGroupId == "")
                XCTAssertTrue(flag.metadata().isReference == false)
                XCTAssertTrue(flag.metadata().slug == "")
                
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
                self.testVisitor?.strategy?.getStrategy().activate("key")
            }
            expectationSync.fulfill()
        }
        
        wait(for: [expectationSync], timeout: 5.0)
    }
}
