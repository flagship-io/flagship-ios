//
//  FSVisitor.swift
//  FlagshipTests
//
//  Created by Adel on 14/10/2021.
//

@testable import Flagship
import XCTest

class FSVisitorTests: XCTestCase {
    /// Fake service
    var fakeService: FSService = .init("gk87t3jggr10c6l6sdob", "apiKy", "alias", "anonym1")

    var apiMockManager: APIManager?
    
    override func setUpWithError() throws {
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        var urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
        fakeService.serviceSession = urlFakeSession
        apiMockManager = APIManager(service: fakeService, userId: "alias", currentContext: [:])
    }

    func testCreateVisitor() {
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "aliastoto", hasConsented: true, instanceType: .NEW_INSTANCE).build()
        XCTAssert(v1.currentFlags.isEmpty)
        XCTAssert(v1.anonymousId == nil)
    }
    
    func testCreateVisitorWithContext() {
        // Flagship.sharedInstance.currentState = .Ready
        /// Check the context
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "alias", hasConsented: true).withContext(context: ["key1": "val1", "key2": "val2", "key3": "val3"]).build()
        /// Update context
        v1.updateContext(["key11": "val11"])
        v1.updateContext(["key11": "val12"])
        XCTAssert(v1.context.getCurrentContext()["key11"] as? String == "val12")
        v1.updateContext("key12", 12)
        XCTAssert(v1.context.getCurrentContext()["key12"] as? Int == 12)
        v1.updateContext("key1", true)
        XCTAssert(v1.context.getCurrentContext()["key1"] as? Bool == true)

        /// Chekc the context with another visitor
        let v2 = Flagship.sharedInstance.newVisitor(visitorId: "aliasBis", hasConsented: true).build()
        /// Update presContext
        v2.updateContext(.CARRIER_NAME, "SFR")
    }
    
    func testSharedVisitorWithCtx() {
        /// Reset
        Flagship.sharedInstance.reset()
        
        /// Re-start the sdk
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")

        /// Create a new instance
        let newVisitor = Flagship.sharedInstance.newVisitor(visitorId: "NEW_INSTANCE", hasConsented: true, instanceType: .NEW_INSTANCE).build()
        XCTAssertNil(Flagship.sharedInstance.sharedVisitor)

        XCTAssertTrue(newVisitor.visitorId == "NEW_INSTANCE")
        
        XCTAssertTrue(newVisitor.hasConsented)

        /// Create single instance
        let singleVisitor = Flagship.sharedInstance.newVisitor(visitorId: "SINGLE_INSTANCE", hasConsented: true, instanceType: .SHARED_INSTANCE).build()
        /// Check if the shared visitor is nil
        XCTAssertNotNil(Flagship.sharedInstance.sharedVisitor)
        
        /// Create a new instance and set as shared instance
        let newVisitorBis = Flagship.sharedInstance.newVisitor(visitorId: "NEW_INSTANCE_BIS", hasConsented: false, instanceType: .NEW_INSTANCE).build()
        XCTAssertFalse(newVisitorBis.hasConsented)
        Flagship.sharedInstance.setSharedVisitor(newVisitorBis)
        XCTAssertNotNil(Flagship.sharedInstance.sharedVisitor)
        
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.visitorId == "NEW_INSTANCE_BIS")
        
        /// Create single instance
        let singleVisitorTer = Flagship.sharedInstance.newVisitor(visitorId: "SINGLE_INSTANCE_TER", hasConsented: true, instanceType: .SHARED_INSTANCE).build()
        
        /// Check if the shared visitor is nil
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.visitorId == "SINGLE_INSTANCE_TER")
        
        /// Create a visitor: "visitor_1" as SINGLE_INSTANCE
        let visitor_1 = Flagship.sharedInstance.newVisitor(visitorId: "visitor_1", hasConsented: true, instanceType: .SHARED_INSTANCE).build()
        /// "visitor_1" updateContext() color = blue
        visitor_1.updateContext("color", "blue")
        
        /// Flagship.getSharedVisitor().getContext()[color]
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.getContext()["color"] as? String == "blue")
        
        /// Create a visitor: "visitor_2" as SINGLE_INSTANCE
        let visitor_2 = Flagship.sharedInstance.newVisitor(visitorId: "visitor_2", hasConsented: true, instanceType: .SHARED_INSTANCE).build()
        XCTAssertNil(Flagship.sharedInstance.sharedVisitor?.getContext()["color"])
        
        /// Flagship.getVisitor().updateContext() color = red
        Flagship.sharedInstance.sharedVisitor?.updateContext("color", "red")
        
        /// "visitor_1" getContext()[color]
        XCTAssertTrue(visitor_1.getContext()["color"] as? String == "blue")
        
        /// "visitor_2" getContext()[color]
        XCTAssertTrue(visitor_2.getContext()["color"] as? String == "red")
        
        /// Flagship.getVisitor().getContext()[color]
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.getContext()["color"] as? String == "red")
    }
}
