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
    

    var serviceTest:ABService = ABService("bkk9glocmjcg0vtmdlng", "userId")
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetCampaign(){
           
        Flagship.sharedInstance.service = serviceTest
        let expectation = self.expectation(description: #function)

        serviceTest.getCampaigns(Dictionary()) { (comp, error) in
            
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10)

    }
    
    
    func testActivate(){
        
        serviceTest.activateCampaignRelativetoKey("key", FSCampaigns("idCamp"))
    }
    
    
    
    /// Send EventTrack
    func testSendEventTrack(){
        
        serviceTest.sendEvent( FSEventTrack(eventCategory: .User_Engagement, eventAction: "testAction"))
        
        serviceTest.sendEvent( FSEventTrack(eventCategory: .Action_Tracking, eventAction: "testAction"))

    }
    
    
    //// Send Item
    func testSendItemEvent(){
        
        let item:FSItemTrack = FSItemTrack(transactionId: "id", name: "testItem")
        
        item.price = nil
        item.code = nil
        item.quantity =  nil
        item.category = nil
        serviceTest.sendEvent(item)
    }
    
    
    /// Send Transaction
    
    func testSendTransaction(){
        
        let item:FSTransactionTrack = FSTransactionTrack(transactionId: "idTransac", affiliation: "affiliation")
        item.couponCode = nil
        item.currency = nil
        item.itemCount = nil
        item.paymentMethod = nil
        item.revenue = nil
        item.tax =  nil
        item.ShippingMethod = nil
        item.shipping = nil
        serviceTest.sendEvent(item)
    }
    
    /// Send Page Track
    func testPageTrack(){
        let item:FSPageTrack =  FSPageTrack("interfaceName")
        serviceTest.sendEvent(item)
    }
    
    
    
    func testsendkeyValueContext(){
     
        serviceTest.sendkeyValueContext(["key1":"", "":true, "key2":12, "key3":["key1":"", "":true, "key2":12]])
    }
    
}
