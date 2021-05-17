//
//  ReconcileTest.swift
//  FlagshipTests
//
//  Created by Adel on 17/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship



class ReconcileTest: XCTestCase {
    
    var serviceTest:ABService!
    let mockUrl = URL(string: "Mock")!
    let expectation = XCTestExpectation(description: "Flagship-Config")
    override func setUpWithError() throws {
        
        
        
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let sessionTest = URLSession.init(configuration: configuration)
        serviceTest = ABService("idClient", "idVisitor", "anounymousA", "apiKey")
        
        /// Set our mock session into service
        serviceTest.sessionService = sessionTest
        
        Flagship.sharedInstance.service = serviceTest
        
        do {
            
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "sampleIdBucket", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            
            MockURLProtocol.requestHandler = { request in
                
                let response = HTTPURLResponse(url:self.mockUrl , statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
        }catch{
            
        }
        
        
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testTupleAuthentication(){
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "apiKey", visitorId: "ABCD-EFGH") { (result) in
            
            
            XCTAssert(Flagship.sharedInstance.visitorId == "ABCD-EFGH")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == nil)
            
            
            /// Set Authenticate
            
            Flagship.sharedInstance.authenticateVisitor(visitorId: "Alex")
            
            XCTAssert(Flagship.sharedInstance.visitorId == "Alex")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == "ABCD-EFGH")
            
            
            /// Set unAuthenticate
            
            Flagship.sharedInstance.unAuthenticateVisitor()
            
            
            XCTAssert(Flagship.sharedInstance.visitorId == "ABCD-EFGH")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == nil)
            
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    
    func testTupleAuthenticationWithLoggedSessionAtSatrt(){
        
        
        /// Start the sdk first
        FSGenerator.saveFlagShipIdInCache(userId: "id123")
        
        let expectation = XCTestExpectation(description: "Flagship-Config")
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "apiKey", visitorId: "Alex", config: FSConfig(authenticated: true)) { (result) in
            XCTAssert(Flagship.sharedInstance.visitorId == "Alex")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == "id123" )
            
            /// Set authenticate
            Flagship.sharedInstance.authenticateVisitor(visitorId: "Alex")
            
            XCTAssert(Flagship.sharedInstance.visitorId == "Alex")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == "id123" )
            
            /// Set unAuthenticate
            
            Flagship.sharedInstance.unAuthenticateVisitor()
            
            XCTAssert(Flagship.sharedInstance.visitorId == "id123")
            
            XCTAssert(Flagship.sharedInstance.anonymousId == nil)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAutheticateWithCtxNil(){
        
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.updateContext(["k1":"v1","k2":"v2"])
        Flagship.sharedInstance.authenticateVisitor(visitorId: "alex", visitorContext:nil) { (result) in
            
            
            /// The context should keep the same keys
            let ctx = Flagship.sharedInstance.getVisitorContext()
            XCTAssert(ctx.count == 2)
            
            XCTAssert(ctx["k1"] as? String == "v1")
            
            XCTAssert(ctx["k2"] as? String == "v2")
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAutheticateWithModifiedContext(){
        
        /// Prepare context as real life cycle
        Flagship.sharedInstance.updateContext(FSPresetContext.getPresetContextForApp())
        Flagship.sharedInstance.updateContext(["k1":"v1","k2":"v2"])
        /// authenticateVisitor with new context
        Flagship.sharedInstance.authenticateVisitor(visitorId: "alex", visitorContext:["k11":"v1","k22":"v2", "k33":"v3", "sdk_deviceLanguage":"fr"]) { (result) in
            
            let ctx = Flagship.sharedInstance.getVisitorContext()
            
            XCTAssert(ctx["k11"] as? String == "v1")
            
            XCTAssert(ctx["k22"] as? String == "v2")
            
            XCTAssert(ctx["sdk_deviceLanguage"] as? String == "fr") /// override the existant key
            
            
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testunAutheticateWithCtxNil(){
        
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.updateContext(["k1":"v1","k2":"v2"])
        Flagship.sharedInstance.authenticateVisitor(visitorId:"alex")
        
        Flagship.sharedInstance.unAuthenticateVisitor(){ (result) in
            
            let ctx = Flagship.sharedInstance.getVisitorContext()
            
            XCTAssert(ctx.count == 2)
            
            XCTAssert(ctx["k1"] as? String == "v1")
            
            XCTAssert(ctx["k2"] as? String == "v2")
            
            self.expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func testunAutheticateWithNoNilCtx(){
        
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.updateContext(["k1":"v1","k2":"v2"])
        Flagship.sharedInstance.authenticateVisitor(visitorId:"alex")
        
        Flagship.sharedInstance.unAuthenticateVisitor(visitorContext:["kilo":"bravo"]){ (result) in
            
            let ctx = Flagship.sharedInstance.getVisitorContext()
            
            XCTAssert(ctx["kilo"] as? String == "bravo")
            
            self.expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testWithBucketing(){
        
        Flagship.sharedInstance.context.cleanContext()
        Flagship.sharedInstance.updateContext(["k1":"v1","k2":"v2"])
        
        // Create config for bucketing
        let config = FSConfig(.BUCKETING, timeout: 2, authenticated: false)
        
        Flagship.sharedInstance.start(envId: "fkk9glocmjcg0vtmdlnh", apiKey: "apikey", visitorId: "Alex", config:config) { (res) in
            
            Flagship.sharedInstance.unAuthenticateVisitor(visitorContext:["kilo":"bravo"])
            
            let ctx = Flagship.sharedInstance.getVisitorContext()
            
            XCTAssert(ctx["kilo"] == nil)
            
            
            Flagship.sharedInstance.authenticateVisitor(visitorId: "alex", visitorContext:["alpha":"bravo"])

            XCTAssert(ctx["alpha"] == nil)
            
            self.expectation.fulfill()
           
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        
        //        wait(for: [expectation], timeout: 5.0)
    }
    
}
