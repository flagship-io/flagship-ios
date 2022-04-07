//
//  FlagshipBucketingTest.swift
//  FlagshipTests
//
//  Created by Adel on 16/11/2021.
//

import XCTest
import Flagship

@testable import Flagship

class FlagshipBucketingTest: XCTestCase {
    
    var testVisitor:FSVisitor?
    var urlFakeSession: URLSession?
    let fsConfig:FlagshipConfig = FSConfigBuilder().Bucketing().build()
    
    override func setUpWithError() throws {

        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        //let urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        /// Start sdk
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey", config:fsConfig)

    }
    
    func testBucketingWithSucess() {
        return
        do {
            
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            
            MockURLProtocol.requestHandler = { _ in
                
                let response = HTTPURLResponse(url:URL(string: "BucketMock")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
        }catch{
            
            print("---------------- Failed to load the buckeMock file ----------")
        }
        
        /// Create new visitor
        testVisitor = Flagship.sharedInstance.newVisitor("bucketUser").build()
        
        /// Erase all cached data
        testVisitor?.strategy?.getStrategy().flushVisitor()
        
        /// Set fake session
        if let aUrlFakeSession = urlFakeSession
        {
           
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
            testVisitor?.configManager.decisionManager?.launchPolling()
        }
        /// Give time to polling
        sleep(5)
        
        let expectationSync = XCTestExpectation(description: "Service-GetScript")
        
        testVisitor?.synchronize(onSyncCompleted: {
            
            let retValue = self.testVisitor?.getModification("key", defaultValue: "default") as? String
            XCTAssertTrue(retValue == "value")
            
            // Get from alloc 100
            let retValue1 = self.testVisitor?.getModification("stringFlag", defaultValue: "default") as? String
            XCTAssertTrue(retValue1 == "alloc_100")

            
            if let infos = self.testVisitor?.getModificationInfo("key"){
                
                XCTAssertTrue((infos["campaignId"]       as? String) == "br6h4dv811lg07g61g00")
                XCTAssertTrue((infos["variationGroupId"] as? String) == "br6h4dv811lg07g61g10")
                XCTAssertTrue((infos["variationId"]      as? String) == "br6h4dv811lg07g61g20")
                XCTAssertTrue((infos["isReference"]      as? Bool) == false)
            }
            expectationSync.fulfill()
        })
        
        wait(for: [expectationSync], timeout: 15.0)
        
        
        /// Create new visitor
        testVisitor = Flagship.sharedInstance.newVisitor("korso").build()
        /// Set fake session
        if let aUrlFakeSession = urlFakeSession
        {
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        sleep(1)
        
        let expectationVisitor2 = XCTestExpectation(description: "test_visitor2")
        
        testVisitor?.synchronize(onSyncCompleted: {
            
            // Get from alloc 100
            let retValue1 = self.testVisitor?.getModification("stringFlag", defaultValue: "default") as? String
            XCTAssertTrue(retValue1 == "default")
            XCTAssertTrue(self.testVisitor?.getModificationInfo("stringFlag") == nil)
            expectationVisitor2.fulfill()
        })
        
        wait(for: [expectationVisitor2], timeout: 5.0)
        
    }
    
}
