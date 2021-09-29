//
//  FlagshipGdprTest.swift
//  FlagshipTests
//
//  Created by Adel on 13/07/2021.
//  Copyright © 2021 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FlagshipGdprTest: XCTestCase {
    
    var serviceTestGdpr: ABService!
    let mockUrl = URL(string: "Mock")!
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        let configurationGdpr = URLSessionConfiguration.default
        configurationGdpr.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configurationGdpr)
        serviceTestGdpr = ABService("idClient", "isVisitor", "aidGdpr", "apiKeyGdpr")
        // Set our mock session into service
        serviceTestGdpr.sessionService = sessionTest
        Flagship.sharedInstance.service = serviceTestGdpr
    }
    
    func testStartOptions(){
        
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "apiKeyGdpr", visitorId: "alias", config: FSConfig(.BUCKETING,hasConsented:true)) { result in
            
            XCTAssert(Flagship.sharedInstance.sdkState.getRgpd() == .AUTHORIZE_TRACKING)
        }
    }
    
    
    func testAPIStartGdpr(){
        
        let expectation = XCTestExpectation(description: "Service-Gdpr")
        
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
            // allow tracking
            Flagship.sharedInstance.consent = false
            Flagship.sharedInstance.onStartDecisionApi { result in
                
            XCTAssertTrue(Flagship.sharedInstance.sdkState.getRgpd() == .UNAUTHORIZE_TRACKING)
            XCTAssertTrue( Flagship.sharedInstance.getModification("variation", defaultInt: 1)  == 1)
            expectation.fulfill()
                
            }

        } catch {

            print("error")
        }
        
        wait(for: [expectation], timeout: 5.0)

    }

}
