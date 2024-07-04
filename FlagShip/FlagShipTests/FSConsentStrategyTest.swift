//
//  FSConsentStrategyTest.swift
//  FlagshipTests
//
//  Created by Adel on 26/11/2021.
//

@testable import Flagship
import XCTest
class FSConsentStrategyTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testVisitorWithConsent() {
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
                
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "newUser", hasConsented: true).withContext(context: [:]).build()
        XCTAssertTrue(v1.hasConsented)
        
        let v2 = Flagship.sharedInstance.newVisitor(visitorId: "newUser", hasConsented: false).withContext(context: [:]).build()
        
        
        let v3 = Flagship.sharedInstance.newVisitor(visitorId: "nc", hasConsented: false).withContext(context: [:]).build()

        
        // Send hit
        v3.strategy?.getStrategy().sendHit(FSPage("pageNC"))
        // Send consent
        v3.strategy?.getStrategy().sendHit(FSConsent(eventCategory: .User_Engagement, eventAction: "NC"))
        // cache + lookup*
        v3.strategy?.getStrategy().cacheVisitor()
        v3.strategy?.getStrategy().lookupHits()
        v3.strategy?.getStrategy().lookupVisitor()

        XCTAssertFalse(v2.hasConsented)
        
        /// Update consent
        v2.hasConsented = true
        XCTAssertTrue(v2.hasConsented)
        
        v2.updateContext(["k1": "V1"])
        let ctx = v2.getContext()
       
        XCTAssertTrue(ctx.keys.contains("k1"))
        
        v2.setConsent(hasConsented: true)
        XCTAssertTrue(v2.hasConsented)
        
        v2.setConsent(hasConsented: false)
        XCTAssertFalse(v2.hasConsented)
    }
}
