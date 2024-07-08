//
//  FlagshipBucketingTest.swift
//  FlagshipTests
//
//  Created by Adel on 16/11/2021.
//

import Flagship
import XCTest

@testable import Flagship

class FlagshipBucketingTest: XCTestCase {
    var testVisitor: FSVisitor?
    var urlFakeSession: URLSession?
    var fsConfig: FlagshipConfig?
    
    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        // let urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        
        do {
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else {
                return
            }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            
            MockURLProtocol.requestHandler = { _ in
                
                let response = HTTPURLResponse(url: URL(string: "BucketMock")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
        } catch {
            print("---------------- Failed to load the buckeMock file ----------")
        }
    }
    
    func testBucketingWithSuccess() {
        let expectationSync = XCTestExpectation(description: "testBucketingWithSuccess")
        
        fsConfig = FSConfigBuilder().Bucketing().withBucketingPollingIntervals(5).build()
        
        /// Start sdk
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey", config: fsConfig ?? FSConfigBuilder().build())
        
        if let aUrlFakeSession = urlFakeSession {
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        
        /// Create new visitor
        testVisitor = Flagship.sharedInstance.newVisitor(visitorId: "alias", hasConsented: true).withFetchFlagsStatus { newStatus, _ in
            
            if newStatus == .FETCHED {
                // Get from alloc 100
                if let flag = self.testVisitor?.getFlag(key: "stringFlag") {
                    if flag.status == .FETCHED {
                        XCTAssertTrue(flag.value(defaultValue: "default") == "alloc_100")
                        // Test Flag metadata already with bucketing file
                        XCTAssertTrue(flag.exists())
                        XCTAssertTrue(flag.metadata().campaignId == "br6h35n811lg0788np8g")
                        XCTAssertTrue(flag.metadata().campaignName == "campaign_name")
                        XCTAssertTrue(flag.metadata().variationId == "br6h35n811lg0788npa0")
                        XCTAssertTrue(flag.metadata().variationName == "variation_name")
                        XCTAssertTrue(flag.metadata().variationGroupId == "br6h35n811lg0788np9g")
                        XCTAssertTrue(flag.metadata().variationGroupName == "varGroup_name")
                        XCTAssertTrue(flag.metadata().isReference == false)
                        XCTAssertTrue(flag.metadata().slug == "slug_description")
                    }
                }
                expectationSync.fulfill()
            }
        }.build()
        
        /// Erase all cached data
        testVisitor?.strategy?.getStrategy().flushVisitor()
        
        testVisitor?.fetchFlags {}

        wait(for: [expectationSync], timeout: 10.0)
    }
    
    func testBucketingWithFailedTargeting() { // The visitor id here make the trageting failed
        let expectationSync = XCTestExpectation(description: "testBucketingWithFailedTargeting")
        fsConfig = FSConfigBuilder().Bucketing().withBucketingPollingIntervals(5).build()
        /// Start sdk
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey", config: fsConfig ?? FSConfigBuilder().build())
        /// Create new visitor
        testVisitor = Flagship.sharedInstance.newVisitor(visitorId: "korso", hasConsented: true).withFetchFlagsStatus { _, _ in
            // Get from alloc 100
            let flag2 = self.testVisitor?.getFlag(key: "stringFlag")
            XCTAssertTrue(flag2?.value(defaultValue: "default") == "default")
            expectationSync.fulfill()
        }.build()
        /// Erase all cached data
        testVisitor?.strategy?.getStrategy().flushVisitor()
        testVisitor?.fetchFlags {}

        wait(for: [expectationSync], timeout: 10.0)
    }
}
