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
        
        
        Flagship.sharedInstance.visitorId = ""
        
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
        
        
        /// send with other func
        Flagship.sharedInstance.sendEventTrack(eventHit)
        
   
        
    }
    
    
    func testSendPageHit(){
        
        Flagship.sharedInstance.sendHit( FSPage("interfaceName"))
        
        /// Send with other func
        Flagship.sharedInstance.sendScreenEvent(FSScreen("interfaceName"))
 
       
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
        
        /// Send with other func
        Flagship.sharedInstance.sendTransactionEvent(transac)
    }
    
    
    func testSendItem(){
        
        
        let item:FSItem = FSItem(transactionId: "id", name: "testItem", code: "code")
        
        item.price = nil
        item.quantity =  nil
        item.category = nil
        Flagship.sharedInstance.sendHit(item)
        
        /// Send with other func
        Flagship.sharedInstance.sendItemEvent(item)
    }
    
    
    func testFSTrack(){
        
        
        let tr = FSTracking()
        tr.clientId = "cid"
        tr.sessionNumber = 12
        tr.dataSource = "app"
        tr.fsUserId = "userId"
        tr.sessionEventNumber = 13
        tr.currentSessionTimeStamp = 1111
        tr.visitorId = "custom"
        tr.queueTime = 123456
        tr.userIp = "1111.1111.111.111"
        tr.screenResolution = "resolution"
        tr.screenColorDepth = "depth"
        tr.userLanguage = "fr"
        
        
        let dicoCommun = tr.communBodyTrack
        
        
        
        XCTAssertTrue(dicoCommun["vid"] as? String == "custom")
        XCTAssertTrue(dicoCommun["ds"] as? String == "app")
        XCTAssertTrue(dicoCommun["uip"] as? String == "1111.1111.111.111")
        XCTAssertTrue(dicoCommun["sr"] as? String == "resolution")
        XCTAssertTrue(dicoCommun["sd"] as? String == "depth")
        XCTAssertTrue(dicoCommun["ul"] as? String == "fr")
        XCTAssertTrue(dicoCommun["sn"] as? Double == 12)
       // XCTAssertTrue(dicoCommun["dl"] as? String == "iName")
 
        
        let trBis = FSTracking()
       // trBis.customVisitorId = "custom"

        let dicoCommunBis = trBis.communBodyTrack
        
        print(dicoCommunBis)
            
        XCTAssertTrue(dicoCommunBis["vid"] as? String == "")
        XCTAssertTrue(dicoCommunBis["ds"]  as? String  == "APP")
        XCTAssertTrue(dicoCommunBis["cid"] as? String == "")

    }
    
    
    func testTransaction(){
        
        let transacTest = FSTransaction(transactionId: "idTransac", affiliation: "affiliation")
        
        XCTAssertTrue(transacTest.transactionId == "idTransac")
        XCTAssertTrue(transacTest.affiliation == "affiliation")
        transacTest.revenue = 12
        transacTest.shipping = 13
        transacTest.tax = 0.4
        transacTest.currency = "euro"
        transacTest.couponCode = "Code"
        transacTest.paymentMethod = "PM"
        transacTest.shippingMethod = "SM"
        transacTest.itemCount = 4
        
        let dico = transacTest.bodyTrack
        
        XCTAssertTrue(dico["t"] as? String == FSTypeTrack.TRANSACTION.typeString)
        XCTAssertTrue(dico["tid"] as? String == "idTransac")
        XCTAssertTrue(dico["ta"] as? String == "affiliation")
        XCTAssertTrue(dico["tr"] as? NSNumber == 12)
        XCTAssertTrue(dico["ts"] as? NSNumber == 13)
        XCTAssertTrue(dico["tt"] as? NSNumber == 0.4)
        XCTAssertTrue(dico["tc"] as? String == "euro")
        XCTAssertTrue(dico["tcc"] as? String == "Code")
        XCTAssertTrue(dico["pm"] as? String == "PM")
        XCTAssertTrue(dico["sm"] as? String == "SM")
        XCTAssertTrue(dico["icn"] as? NSNumber == 4)
    }
    
    func testEvent(){
        
        let eventTest = FSEvent(eventCategory: .Action_Tracking, eventAction: "eventAction")
        eventTest.label = "label"
        eventTest.eventValue = 4
        
        let dico = eventTest.bodyTrack
        
        XCTAssertTrue(dico["t"]  as? String == FSTypeTrack.EVENT.typeString)
        XCTAssertTrue(dico["ec"]  as? String == FSCategoryEvent.Action_Tracking.categoryString)
        XCTAssertTrue(dico["ev"] as? NSNumber == 4)
        XCTAssertTrue(dico["el"] as? String == "label")
        XCTAssertTrue(dico["ea"] as? String == "eventAction")
        
        let eventTestBis = FSEvent(eventCategory: .User_Engagement, eventAction: "eventAction")
        let dicoBis = eventTestBis.bodyTrack
        XCTAssertTrue(dicoBis["ec"]  as? String == FSCategoryEvent.User_Engagement.categoryString)
    }
    
    
    func testItem(){
        
        let itemEvent = FSItem(transactionId: "idItem", name: "itemName", code: "code")
        
        itemEvent.price = 111
        itemEvent.quantity = 12
        itemEvent.category = "category"
        let dico = itemEvent.bodyTrack
        
        XCTAssertTrue(dico["t"]    as? String == FSTypeTrack.ITEM.typeString)
        XCTAssertTrue(dico["tid"]  as? String == "idItem")
        XCTAssertTrue(dico["in"] as? String == "itemName")
        XCTAssertTrue(dico["ip"] as? NSNumber == 111)
        XCTAssertTrue(dico["iq"] as? NSNumber == 12)
        XCTAssertTrue(dico["ic"] as? String == "code")
        XCTAssertTrue(dico["iv"] as? String == "category")
    }
    
    
    func testPage(){
        
        let itemPage = FSPage("pageTest")
        let dico = itemPage.bodyTrack
        XCTAssertTrue(dico["t"]    as? String == FSTypeTrack.SCREEN.typeString)
        XCTAssertTrue(dico["dl"]    as? String == "pageTest")
    }
}

