//
//  FSettingsTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 24/12/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSettingsTest: XCTestCase {
    var fsConfig: FlagshipConfig?
    var urlFakeSession: URLSession?
    var listOfData: [Data] = []

    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)

        let listofFile = ["settings", "score"]
        // ===> [data of ressource, data of score]
        // Load Setting and Score
        do {
            let testBundle = Bundle(for: type(of: self))

            for file in listofFile {
                guard let path = testBundle.url(forResource: file, withExtension: "json") else {
                    return
                }

                try listOfData.append(Data(contentsOf: path, options: .alwaysMapped))
            }
        } catch {
            print("---------------- Failed to load the buckeMock file ----------")
        }
    }

    func testRessource() {
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: URL(string: "settings")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.listOfData.first)
        }

        let setting = FSSettings()
        setting.session = urlFakeSession ?? URLSession(configuration: .ephemeral)

        let expectationSync = XCTestExpectation(description: "fetch ressource")
        setting.fetchRessources(envId: "envId", completion: { extra, error in
            if extra != nil {
                XCTAssertTrue(extra?.accountSettings?.eaiActivationEnabled ?? false)
                XCTAssertTrue(extra?.accountSettings?.eaiCollectEnabled ?? false)
                XCTAssertNil(error)

            } else {
                XCTFail("Failed to fetch extra")
            }
            expectationSync.fulfill()
        })
        wait(for: [expectationSync], timeout: 5.0)
    }

    func testFetchScore() {
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: URL(string: "settings")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, self.listOfData.last)
        }

        let setting = FSSettings()
        setting.session = urlFakeSession ?? URLSession(configuration: .ephemeral)

        let expectationSync = XCTestExpectation(description: "fetch score")
        setting.fetchScore(visitorId: "userTest") { score, _ in

            XCTAssertEqual(score, "Immediacy")
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 6.0)
    }
}
