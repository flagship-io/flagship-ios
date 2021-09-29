//
//  FSServiceTest.swift
//  FlagshipTests
//
//  Created by Adel on 19/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship
import SystemConfiguration
import Network

class FSServiceTest: XCTestCase {

    var serviceTest: ABService!
    let mockUrl = URL(string: "Mock")!

    override func setUp() {

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceTest = ABService("idClient", "isVisitor", "anunymA", "apiKey")

        /// Set our mock session into service
        serviceTest.sessionService = sessionTest

    }

    func testInit() {

        let service =  ABService("clientId", "visitorId", nil, "apiKey")

        XCTAssertTrue(service.anonymousId == nil)

        XCTAssertTrue(service.visitorId == "visitorId")

        let serviceBis =  ABService("clientId", "visitorId", "iAd", "apiKey")

        XCTAssertTrue(serviceBis.anonymousId == "iAd")

    }

    func testActivate() {

        serviceTest.activateCampaignRelativetoKey("key", FSCampaigns("idCamp"))

     }

    func testsendkeyValueContext() {

        serviceTest.sendkeyValueContext(["key1": "", "": true, "key2": 12, "key3": ["key1": "", "": true, "key2": 12]])

    }

    func testSendTracking() {

        serviceTest.sendTracking(FSEvent(eventCategory: .Action_Tracking, eventAction: "act"))

     }

    //// Get Campaign
    func testGetCampaignWithSucess() {
        /// Create the mock response
        /// Load the data

        let expectation = XCTestExpectation(description: "Service-expectation")

        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }

            serviceTest.getCampaigns([:]) { (camp, _) in

                if let campaign = camp {

                    XCTAssert(campaign.visitorId == "2020072318165329233")
                    XCTAssert(campaign.campaigns.count == 3)
                    XCTAssert(campaign.campaigns.first?.idCampaign == "bsffhle242b2l3igq4dg")
                    XCTAssert(campaign.campaigns.first?.variationGroupId == "bsffhle242b2l3igq4egaa")

                    /// Test activate
                    self.serviceTest.activateCampaignRelativetoKey("array", campaign)
                    self.serviceTest.activateCampaignRelativetoKey("complex", campaign)
                    self.serviceTest.activateCampaignRelativetoKey("object", campaign)
                    self.serviceTest.activateCampaignRelativetoKey("", campaign)
                    self.serviceTest.activateCampaignRelativetoKey("object", campaign)
                    self.serviceTest.activateCampaignRelativetoKey("noone", campaign)

                }

            expectation.fulfill()

            }

         } catch {

            print("error")
        }

        wait(for: [expectation], timeout: 5.0)

    }

    func testGetCampaignWithFailureParsing() {
        let data =  Data()

        let expectation = XCTestExpectation(description: "Service-FailureParsing")

          MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: self.mockUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
              return (response, data)
          }

          serviceTest.getCampaigns([:]) { (_, error) in

            XCTAssert(error == FlagshipError.GetCampaignError)

            self.serviceTest.activateCampaignRelativetoKey("array", FSCampaigns(""))

              expectation.fulfill()

          }

          wait(for: [expectation], timeout: 5.0)
    }

    func testWithNot200OK() {

        let expectation = XCTestExpectation(description: "Service-200OK")
        let data =  Data()

          MockURLProtocol.requestHandler = { _ in

            let response = HTTPURLResponse(url: self.mockUrl, statusCode: 0, httpVersion: nil, headerFields: nil)!
              return (response, data)
          }

        serviceTest.getCampaigns([:]) { (_, error) in

          XCTAssert(error == FlagshipError.GetCampaignError)
            self.serviceTest.activateCampaignRelativetoKey("array", FSCampaigns(""))

            expectation.fulfill()

        }

        wait(for: [expectation], timeout: 5.0)

    }

    func testTimeOutValue() {

        let expectation = XCTestExpectation(description: "Service-Timeout")

        let serviceTestWithTimeOut: ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "aid1", "apiKey", timeoutService: 1)

        let serviceTestWithTimeOutBis: ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "aid1", "apiKey", timeoutService: 2)

        let serviceTestWithTimeOutTer: ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "aid1", "apiKey", timeoutService: 3)

          serviceTestWithTimeOut.getCampaigns([:]) { (_, _) in

            XCTAssert( serviceTestWithTimeOut.timeOutServiceForRequestApi  == 1)
            XCTAssert( serviceTestWithTimeOutBis.timeOutServiceForRequestApi  == 2)
            XCTAssert( serviceTestWithTimeOutTer.timeOutServiceForRequestApi  == 3)

            expectation.fulfill()

          }

        wait(for: [expectation], timeout: 5.0)
    }

}
