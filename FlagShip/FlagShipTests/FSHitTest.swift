//
//  FSHitTest.swift
//  FlagshipTests
//
//  Created by Adel on 01/04/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship



class FSHitTest: XCTestCase {
    
    override func setUp() {
        
        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(environmentId: "bkk9glocmjcg0vtmdlng", "alias", .DECISION_API) { (result) in
            
            XCTAssert(result == .Ready)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
        
    }
    
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    
    func testSendEventhit(){
        
        let eventHit = FSEvent(eventCategory: .Action_Tracking, eventAction: "value")
        Flagship.sharedInstance.sendHit(eventHit)
        
        
        let eventHitBis = FSEvent(eventCategory: .User_Engagement, eventAction: "value")
        Flagship.sharedInstance.sendHit(eventHitBis)
        
    }
    
    
    func testSendPageHit(){
        
        Flagship.sharedInstance.sendHit( FSPage("interfaceName"))
       
    }
    
    func testSendTransactionHit(){
        
        let transac:FSTransaction = FSTransaction(transactionId: "idTransac", affiliation: "affiliation")
        transac.couponCode = nil
        transac.currency = nil
        transac.itemCount = nil
        transac.paymentMethod = nil
        transac.revenue = nil
        transac.tax =  nil
        transac.shippingMethod = nil
        transac.shipping = nil
        Flagship.sharedInstance.sendHit(transac)
    }
    
    
    func testSendItem(){
        
        
        let item:FSItem = FSItem(transactionId: "id", name: "testItem")
        
        item.price = nil
        item.code = nil
        item.quantity =  nil
        item.category = nil
        Flagship.sharedInstance.sendHit(item)
    }
    
    

}
