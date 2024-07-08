//
//  FSAllFlagTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 03/06/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSAllFlagTest: XCTestCase {
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
                let response = HTTPURLResponse(url: URL(string: "ok")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
        } catch {
            print("---------------- FSAllFlagTest- Failed to load the mock api file ----------")
        }
    }
    
    // Normal behaviour
    func testAbsoluteGetFlags() {
        // Create Visitor
        let userAllFlag: FSVisitor = Flagship.sharedInstance.newVisitor(visitorId: "userAllFlag", hasConsented: true).build()
        // Set fake session
        if let aUrlFakeSession = urlFakeSession {
            userAllFlag.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        
        let expecAllFlag = XCTestExpectation(description: "Get All Flags")
        // FetchFlags
        userAllFlag.fetchFlags {
            let collectionFlag = userAllFlag.getFlags()
            XCTAssertTrue(collectionFlag.count == 4) // should contain 4 flags
            XCTAssertFalse(collectionFlag.isEmpty) // Should not be empty
            XCTAssertTrue(collectionFlag.keys().count == 4) // Should be 4
                
            // Apply filter
            let result = collectionFlag.filter { (key: String, _: FSFlag) in
                    
                key == "isMenuUpdateVisible"
            }
            XCTAssert(result.count == 1)
            // Apply iterator
            var index = 0
            collectionFlag.forEach { (_: String, _: FSFlag) in
                index += 1
            }
            XCTAssertTrue(index == 4)
                
            // Test metadata for collection
            let metadataArray = collectionFlag.metadatas()
            XCTAssertEqual(metadataArray.count, 4)
            metadataArray.forEach { item in
                XCTAssertEqual(item.campaignId, "bvcdqksmicqghldq9agg")
                XCTAssertEqual(item.campaignName, "campaign_name")
            }
            // Test json representation
            let collectionString = collectionFlag.toJson()
            let data = Data(collectionString.utf8)
            do {
                // make sure this JSON is in the format we expect
                if let ConvertedArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    try ConvertedArray.forEach { subDico in
                        if subDico["key"] as? String == "btnTitle" {
                            if let hexValue = subDico["hex"] as? String {
                                let decodedHex = Hex.hexToStr(text: hexValue)
                                let dataBis = Data(decodedHex.utf8)
                                if let ConvertedHEx = try JSONSerialization.jsonObject(with: dataBis, options: []) as? [String: Any] {
                                    XCTAssertTrue(ConvertedHEx["v"] as? String == "Alpha_demoApp")
                                }
                            }
                        }
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
                
            expecAllFlag.fulfill()
        }
        
        wait(for: [expecAllFlag], timeout: 5.0)
    }
    
    func testWithBadKeysGetFlags() {
        let expecAllFlag = XCTestExpectation(description: "Get All FlagsBadKey")
        
        // Create Visitor
        let userAllFlagBis: FSVisitor = Flagship.sharedInstance.newVisitor(visitorId: "userAllFlag", hasConsented: true).build()
        // Set fake session
        if let aUrlFakeSession = urlFakeSession {
            userAllFlagBis.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        
        // FetchFlags
        userAllFlagBis.fetchFlags {
            let collectionFlag = userAllFlagBis.getFlags()
            let badFlag: FSFlag = collectionFlag["badKey"]
            XCTAssertTrue(badFlag.key == "badKey")
            XCTAssertNil(badFlag.defaultValue)
            XCTAssertNil(badFlag.strategy)
            XCTAssertTrue(badFlag.value(defaultValue: "dflValue") == "dflValue")
            XCTAssertFalse(badFlag.exists())
            XCTAssertEqual(badFlag.metadata().campaignId, "")
            XCTAssertEqual(collectionFlag.count, 4)
            
            expecAllFlag.fulfill()
        }

        wait(for: [expecAllFlag], timeout: 5.0)
    }
    
    func testReadingFlag() {
        let expecAllFlag = XCTestExpectation(description: "Get All Flags")
        
        // Create Visitor
        let userAllFlagTer: FSVisitor = Flagship.sharedInstance.newVisitor(visitorId: "userAllFlag", hasConsented: true).build()
        // Set fake session
        if let aUrlFakeSession = urlFakeSession {
            userAllFlagTer.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
        
        // FetchFlags
        userAllFlagTer.fetchFlags {
            let readFlag = userAllFlagTer.getFlag(key: "btnTitle")
            // Should return a default value
            XCTAssertEqual(readFlag.value(defaultValue: 12), 12)
            // Should return a default value
            XCTAssertEqual(readFlag.value(defaultValue: 12.4), 12.4)
            // Should return a default value
            XCTAssertEqual(readFlag.value(defaultValue: false), false)
            // Should return a default value
            XCTAssertEqual(readFlag.value(defaultValue: [1, 2, 3]), [1, 2, 3])
            // Check reading value
            XCTAssertEqual(readFlag.value(defaultValue: "default"), "Alpha_demoApp")
            expecAllFlag.fulfill()
        }
        wait(for: [expecAllFlag], timeout: 5.0)
    }
}
