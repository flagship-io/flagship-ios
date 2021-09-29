//
//  FlagshipTestWithMockedData.swift
//  FlagshipTests
//
//  Created by Adel on 29/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FlagshipTestWithMockedData: XCTestCase {

    //  var flagShipMock:FlagshipMock!

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
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

     //   synchronizeModifications()

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testOnSatrtBucketingWithFailed() {

        /// Create the mock response
        /// Load the data

        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
            // add file name
            url.appendPathComponent("bucket.json")

            if FileManager.default.fileExists(atPath: url.path) == true {

                do {

                    try FileManager.default.removeItem(at: url)

                } catch {

                    //
                }

            } else {

                /////
            }
        }

        let expectation = XCTestExpectation(description: "Flagship-GetScript")

        let data = Data()
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: self.mockUrl, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        // Set visitor id
        Flagship.sharedInstance.setVisitorId("202072017183814142")
        // set context
        Flagship.sharedInstance.updateContext(ALL_USERS, "")

        Flagship.sharedInstance.onStartBucketing { (result) in

            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testOnSatrtBucketingWithSucess() {

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-GetScript")

        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "sampleIdBucket", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
            // Set visitor id
            Flagship.sharedInstance.setVisitorId("202072017183814142")
            // set context
            Flagship.sharedInstance.updateContext(ALL_USERS, "")
            Flagship.sharedInstance.onStartBucketing { (result) in
                
                // Authorize tracking
                Flagship.sharedInstance.consent = true
                XCTAssert(result == .Ready)
                // Check the value variation
                XCTAssert(Flagship.sharedInstance.getModification("variation", defaultInt: 1) == 4)
                // Check the value variation50
                XCTAssert(Flagship.sharedInstance.getModification("variation50", defaultInt: 0, activate: true) == 1)
                XCTAssertTrue(Flagship.sharedInstance.getModification("variationBool", defaultBool: false, activate: true) == true)
                XCTAssertTrue(Flagship.sharedInstance.getModification("variationString", defaultString: "none", activate: true) == "value")
                XCTAssertTrue(Flagship.sharedInstance.getModification("variationDouble", defaultDouble: 3.14, activate: true) == 4.333)

                XCTAssertTrue(Flagship.sharedInstance.getAllModification().count > 0)

                Flagship.sharedInstance.disabledSdk = false

                expectation.fulfill()
            }

        } catch {

            print("error")
        }

        wait(for: [expectation], timeout: 10.0)
    }
    func testonStartDecisionApiWithSucess() {

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-GetScript")

        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }

            // Set visitor id
            Flagship.sharedInstance.setVisitorId("202072017183814142")
            // set context
            Flagship.sharedInstance.updateContext(ALL_USERS, "")

            Flagship.sharedInstance.onStartDecisionApi { (result) in
                
                Flagship.sharedInstance.consent = true

                XCTAssert(result == .Ready)

                /// Check array
                let array = Flagship.sharedInstance.getModification("array", defaultArray: [])

                XCTAssert(array.count == 3)

                /// Chekc Dico (json)
                let dico = Flagship.sharedInstance.getModification("object", defaultJson: [:])

                if let val = dico["value"] as? Int {

                    XCTAssert(val == 123456)
                }

                /// Complex object
                let valCpx = Flagship.sharedInstance.getModification("complex", defaultJson: [:])

                if let subCpx = valCpx["carray"] as? [[String: Any]] {

                    if let subDico = subCpx.first {

                        XCTAssert(subDico["cobject"] as? Int == 0)
                    }
                }
                
                /// Check the get information for flag
                if let infos = Flagship.sharedInstance.getModificationInfo(key: "array") {
                    XCTAssert(infos.count == 4)
                    XCTAssertTrue(infos["variationGroupId"] as? String == "bsffhle242b2l3igq4egaa")
                    XCTAssertTrue(infos["campaignId"]       as? String == "bsffhle242b2l3igq4dg")
                    XCTAssertTrue(infos["variationId"]      as? String == "bsffhle242b2l3igq4f0")
                }
                expectation.fulfill()
            }

        } catch {

            print("error")
        }

        wait(for: [expectation], timeout: 5.0)

    }

    func testOnSatrtDecisionApiWithFailed() {

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Flagship-GetScript")

        let data = Data()
        MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: self.mockUrl, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        // Set visitor id
        Flagship.sharedInstance.setVisitorId("202072017183814142")
        // set context
        Flagship.sharedInstance.updateContext(ALL_USERS, "")

        Flagship.sharedInstance.onStartDecisionApi { (result) in

            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testonStartDecisionApiWithWrongFormat() {

        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-GetScript")

        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApiBis", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }

            // Set visitor id
            Flagship.sharedInstance.setVisitorId("202072017183814142")
            // set context
            Flagship.sharedInstance.updateContext(ALL_USERS, "")

            Flagship.sharedInstance.onStartDecisionApi { (result) in

                XCTAssert(result == .NotReady)

                expectation.fulfill()
            }

        } catch {

            print("error")
        }

        wait(for: [expectation], timeout: 5.0)

    }

    //// test synchronizeModifications

    func synchronizeModifications() {

        /// prepare data mock

        let expectation = XCTestExpectation(description: "Flagship-GetScript")

        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }

        } catch {

            return
        }

        Flagship.sharedInstance.sdkModeRunning = .DECISION_API
        Flagship.sharedInstance.setVisitorId("202072017183814142")

        Flagship.sharedInstance.synchronizeModifications { (result) in

            XCTAssert(result == .Updated)

            /// Check array
            let array = Flagship.sharedInstance.getModification("array", defaultArray: [])

            XCTAssert(array.count == 3)

            /// Chekc Dico (json)
            let dico = Flagship.sharedInstance.getModification("object", defaultJson: [:])

            if let val = dico["value"] as? Int {

                XCTAssert(val == 123456)
            }

            /// Complex object
            let valCpx = Flagship.sharedInstance.getModification("complex", defaultJson: [:])

            if let subCpx = valCpx["carray"] as? [[String: Any]] {

                if let subDico = subCpx.first {

                    XCTAssert(subDico["cobject"] as? Int == 0)
                }
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5.0)
    }

}
