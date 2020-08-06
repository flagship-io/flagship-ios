//
//  FSServiceTest.swift
//  FlagshipTests
//
//  Created by Adel on 19/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSServiceTest: XCTestCase {
    
   
    var expectation: XCTestExpectation!
    var serviceTest:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey")
    let mockUrl = URL(string: "Mock")!
    
    override func setUp() {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceTest = ABService("idClient", "isVisitor", "apiKey")
        
        /// Set our mock session into service
        serviceTest.sessionService = sessionTest
        expectation = expectation(description: "Service-expectation")
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
 
 
 
    
    
    func testActivate(){
        
        serviceTest.activateCampaignRelativetoKey("key", FSCampaigns("idCamp"))
        
     }
    
    
    func testsendkeyValueContext(){
        
        serviceTest.sendkeyValueContext(["key1":"", "":true, "key2":12, "key3":["key1":"", "":true, "key2":12]])
        
        
    }
    
    
    func testSendTracking(){
        
 
        serviceTest.sendTracking(FSEvent(eventCategory: .Action_Tracking, eventAction: "act"))
        
 
     }
    
    
    //// Get Campaign
    func testGetCampaignWithSucess(){
        /// Create the mock response
        /// Load the data
        let mockUrl = URL(string: "Mock")!

        do {
            
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            
            MockURLProtocol.requestHandler = { request in
                
                let response = HTTPURLResponse(url:self.mockUrl , statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
            
             
            
            serviceTest.getCampaigns([:]) { (camp, error) in
                
                
                if let campaign = camp {
                    
                    XCTAssert(campaign.visitorId == "2020072318165329233")
                    XCTAssert(campaign.campaigns.count == 1)
                    XCTAssert(campaign.campaigns.first?.idCampaign == "bsffhle242b2l3igq4dg")
                    XCTAssert(campaign.campaigns.first?.variationGroupId == "bsffhle242b2l3igq4eg")
                }
                
                self.expectation.fulfill()
                
            }
            
            wait(for: [expectation], timeout: 1.0)
            
         }catch{
            
            print("error")
        }

    }
    
    
    func testGetCampaignWithFailureParsing(){
        let data =  Data()
          
          MockURLProtocol.requestHandler = { request in
              
            let response = HTTPURLResponse(url:self.mockUrl , statusCode: 200, httpVersion: nil, headerFields: nil)!
              return (response, data)
          }
          
          serviceTest.getCampaigns([:]) { (camp, error) in
            
            XCTAssert(error == FlagshipError.GetCampaignError)
              
              self.expectation.fulfill()
              
          }
          
          wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testWithNot200OK(){
        
        let data =  Data()
          
          MockURLProtocol.requestHandler = { request in
              
            let response = HTTPURLResponse(url:self.mockUrl , statusCode:0, httpVersion: nil, headerFields: nil)!
              return (response, data)
          }
        
        
        serviceTest.getCampaigns([:]) { (camp, error) in
          
          XCTAssert(error == FlagshipError.GetCampaignError)
            
            self.expectation.fulfill()
            
        }
        
        wait(for: [expectation], timeout: 1.0)
          
        
    }
    
    
    
    
    
    
    
    
    
    
    
    func testTimeOutValue(){
        
        let serviceTestWithTimeOut:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey", timeoutService:1)

        let serviceTestWithTimeOutBis:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey", timeoutService:2)

        let serviceTestWithTimeOutTer:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId", "apiKey", timeoutService:3)

        
 
          serviceTestWithTimeOut.getCampaigns([:]) { (camp, error) in
              
            
            XCTAssert( serviceTestWithTimeOut.timeOutServiceForRequestApi  == 1)
            XCTAssert( serviceTestWithTimeOutBis.timeOutServiceForRequestApi  == 2)
            XCTAssert( serviceTestWithTimeOutTer.timeOutServiceForRequestApi  == 3)

            self.expectation.fulfill()

          }
          
        wait(for: [expectation], timeout: 1.0)
    }
    
}
