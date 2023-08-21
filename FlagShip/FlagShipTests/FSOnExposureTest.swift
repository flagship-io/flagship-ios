//
//  FSOnExposureTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 16/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSOnExposureTest: XCTestCase {
    var testVisitor: FSVisitor?
    var urlFakeSession: URLSession?

    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        // let urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        let fsConfig = FSConfigBuilder().DecisionApi().withOnVisitorExposed { v, f in

            XCTAssertTrue(v.id == "onVisitorCallBackTest")
            XCTAssertTrue(v.anonymousId == nil)

            // Flag
            XCTAssertTrue(f.value as! String == "Alpha_demoApp")
            XCTAssertTrue(f.defaultValue as! String == "dfl")

        }.build()

        // Start sdk
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
        testVisitor = Flagship.sharedInstance.newVisitor("onVisitorCallBackTest").build()
        /// Set fake session
        if let aUrlFakeSession = urlFakeSession {
            testVisitor?.configManager.decisionManager?.networkService.serviceSession = aUrlFakeSession
        }
    }

    func testOnExposure() {
        let expectationSync = XCTestExpectation(description: "Service-OnExposure")

        testVisitor?.fetchFlags(onFetchCompleted: {
            if let flag = self.testVisitor?.getFlag(key: "btnTitle", defaultValue: "dfl") {
                XCTAssertTrue(flag.value() as! String == "Alpha_demoApp")
            }
            expectationSync.fulfill()

        })
        wait(for: [expectationSync], timeout: 5.0)
    }

    /// Test Flag object
    func testFlagObject() {
        let flagTest = FSExposedFlag(key: "keyFlag", defaultValue: "dfl", metadata: FSFlagMetadata(FSModification(campId: "campId", varGroupId: "grpId", varId: "varId", typeOfTest: "AB", aSlug: "slugg", val: "flagVlaue")), value: "flagVlaue")

        XCTAssertTrue(flagTest.toDictionary()["value"] as? String == "flagVlaue")
        XCTAssertTrue(flagTest.toDictionary()["key"] as? String == "keyFlag")
        XCTAssertTrue(flagTest.metadata.campaignId == "campId")
        XCTAssertTrue(flagTest.toJson()?.length ?? 0 > 0)
    }

    /// Test Visitor Object
    func testVisitorObject() {
        let visitorObject = FSVisitorExposed(id: "testId", anonymousId: "ano1", context: ["key1": "val1"])
        XCTAssertTrue(visitorObject.toDictionary()["id"] as? String == "testId")
        XCTAssertTrue(visitorObject.toDictionary()["anonymousId"] as? String == "ano1")
        XCTAssertTrue((visitorObject.toDictionary()["context"] as? [String: Any])?["key1"] as? String == "val1")
        XCTAssertTrue(visitorObject.toJson()?.length ?? 0 > 0)
    }
}
