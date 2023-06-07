//
//  FSVisitor.swift
//  FlagshipTests
//
//  Created by Adel on 14/10/2021.
//

import XCTest
@testable import Flagship

class FSVisitorTests: XCTestCase {
    
    /// Fake service
    var fakeService:FSService = FSService("gk87t3jggr10c6l6sdob", "apiKy", "alias", "anonym1")

    var apiMockManager:APIManager?
    
    override func setUpWithError() throws {
        
        /// Configuration
        let configuration = URLSessionConfiguration.ephemeral
        /// Fake session
        var urlFakeSession: URLSession!
        configuration.protocolClasses = [MockURLProtocol.self]
        urlFakeSession = URLSession(configuration: configuration)
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")
        fakeService.serviceSession = urlFakeSession
        apiMockManager = APIManager(service:fakeService, userId: "alias", currentContext:[:])
        
    }

    
    func testCreateVisitor(){
        let v1 = Flagship.sharedInstance.newVisitor("aliastoto", instanceType: .NEW_INSTANCE).build()
        XCTAssert(v1.currentFlags.isEmpty)
        XCTAssert(v1.anonymousId == nil)
    }
    
    func testCreateVisitorWithContext(){
        
        //Flagship.sharedInstance.currentState = .Ready
        /// Check the context
        let v1 = Flagship.sharedInstance.newVisitor("alias").withContext(context: ["key1" : "val1","key2" : "val2","key3" : "val3"]).build()
        /// Update context
        v1.updateContext(["key11" : "val11"])
        v1.updateContext(["key11" : "val12"])
        XCTAssert(v1.context.getCurrentContext()["key11"] as? String == "val12")
        v1.updateContext("key12", 12)
        XCTAssert(v1.context.getCurrentContext()["key12"] as? Int == 12)
        v1.updateContext("key1", true)
        XCTAssert(v1.context.getCurrentContext()["key1"] as? Bool == true)

        /// Chekc the context with another visitor
        let v2 = Flagship.sharedInstance.newVisitor("aliasBis").build()
        /// Update presContext
        v2.updateContext(.CARRIER_NAME, "SFR")

    }
    
    func testSynchronize(){
        let syncVisitor = Flagship.sharedInstance.newVisitor("aliasMock").build()
        syncVisitor.configManager.decisionManager = self.apiMockManager
        
        // Set mock data
        do {

            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "decisionApi", withExtension: "json") else { return  }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            MockURLProtocol.requestHandler = { _ in

                let response = HTTPURLResponse(url:URL(string: "Mock")! ,  statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, data)
            }
        }catch{
            
        }
        
        let expectation = XCTestExpectation(description: "response")
        
        syncVisitor.synchronize { 
            
            XCTAssert(syncVisitor.getModification("background_color", defaultValue: "None") == "#000000")
            XCTAssert(syncVisitor.getModification("btnTitle", defaultValue: "None") == "Alpha_demoApp")
           
            /// Revoir le type Generic 
            let dic:[String:Any] = ["zz":2]
            let list = syncVisitor.getModification("config", defaultValue:dic)
            print(list.count)
            
          
            let val = list["lists"] as? [Any]
            XCTAssert(val?.count == 3)

 
            
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 10)
    }
    
    
    func testSharedVisitorWithCtx(){
        /// Reset
        Flagship.sharedInstance.reset()
        
        /// Re-start the sdk
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "apiKey")

        /// Create a new instance
        let newVisitor = Flagship.sharedInstance.newVisitor("NEW_INSTANCE",instanceType: .NEW_INSTANCE).build()
        XCTAssertNil(Flagship.sharedInstance.sharedVisitor)

        XCTAssertTrue(newVisitor.visitorId == "NEW_INSTANCE")
        
        /// Create single instance
        let singleVisitor = Flagship.sharedInstance.newVisitor("SINGLE_INSTANCE",instanceType: .SHARED_INSTANCE).build()
        /// Check if the shared visitor is nil
        XCTAssertNotNil(Flagship.sharedInstance.sharedVisitor)
        
        /// Create a new instance and set as shared instance
        let newVisitorBis = Flagship.sharedInstance.newVisitor("NEW_INSTANCE_BIS",instanceType: .NEW_INSTANCE).build()
        Flagship.sharedInstance.setSharedVisitor(newVisitorBis)
        XCTAssertNotNil(Flagship.sharedInstance.sharedVisitor)
        
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.visitorId == "NEW_INSTANCE_BIS")
        
        /// Create single instance
        let singleVisitorTer = Flagship.sharedInstance.newVisitor("SINGLE_INSTANCE_TER",instanceType: .SHARED_INSTANCE).build()
        
        
        /// Check if the shared visitor is nil
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.visitorId == "SINGLE_INSTANCE_TER")
        
 
        /// Create a visitor: "visitor_1" as SINGLE_INSTANCE
        let visitor_1 = Flagship.sharedInstance.newVisitor("visitor_1",instanceType: .SHARED_INSTANCE).build()
        /// "visitor_1" updateContext() color = blue
        visitor_1.updateContext("color", "blue")
        
        /// Flagship.getSharedVisitor().getContext()[color]
        XCTAssertTrue(Flagship.sharedInstance.sharedVisitor?.getContext()["color"] as? String == "blue")
        
        /// Create a visitor: "visitor_2" as SINGLE_INSTANCE
        let visitor_2 = Flagship.sharedInstance.newVisitor("visitor_2",instanceType: .SHARED_INSTANCE).build()
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
