//
//  FSConsentStrategyTest.swift
//  FlagshipTests
//
//  Created by Adel on 26/11/2021.
//

import XCTest
@testable import Flagship
class FSConsentStrategyTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    
    func testVisitorWithConsent(){
        
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
                
        let v1 = Flagship.sharedInstance.newVisitor("newUser").withContext(context: [:]).build()
        XCTAssertTrue(v1.hasConsented)
        
        let v2 = Flagship.sharedInstance.newVisitor("newUser").withContext(context: [:]).hasConsented(hasConsented: false).build()

        XCTAssertFalse(v2.hasConsented)
        
        /// Update consent
        v2.hasConsented = true
        XCTAssertTrue(v2.hasConsented)
        
        
        v2.updateContext(["k1":"V1"])
        let ctx = v2.getContext()
       
        XCTAssertTrue(ctx.keys.contains("k1"))
        
        v2.setConsent(hasConsented: true)
        XCTAssertTrue(v2.hasConsented)
        
        v2.setConsent(hasConsented: false)
        XCTAssertFalse(v2.hasConsented)

    }

}
