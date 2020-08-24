//
//  FlagshipTests.swift
//  FlagshipTests
//
//  Created by Adel on 19/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FlagshipTests: XCTestCase {
    
      var fsCacheMgr:FSCacheManager!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        UserDefaults.standard.removeObject(forKey: FSLastModified_Key)
        fsCacheMgr = FSCacheManager()


        
    }

    override func tearDown() {
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        guard let resultUrl = fsCacheMgr.createUrlForCache() else { return  }
        do {
            try FileManager.default.removeItem(at: resultUrl)
        }catch{
            
        }
         let resultUrlBis = fsCacheMgr.createUrlForCache()
        XCTAssertTrue(resultUrlBis?.absoluteString.count != 0)
    }
 

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    /// Test start Flagship
//    func testStartFlagshipWithBadEnvId(){
//        
//        let expectation = self.expectation(description: #function)
//        
//        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlo0", apiKey: "j2jL0rzlgVaODLw2Cl4JC3f4MflKrMgIaQOENv36", visitorId: "ee") { (result) in
//            
//            XCTAssert(result == .Ready)
//            expectation.fulfill()
//        }
//  
//        waitForExpectations(timeout: 10)
//       
//    }
    
    
    func testStartFlagshipwithEmptyUserID(){

        let expectation = self.expectation(description: #function)
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "", visitorId: "ee") { (result) in
             
             XCTAssert(result == .NotReady)
             expectation.fulfill()
         }
  
        waitForExpectations(timeout: 10)
       
    }
    
    

    func testStartFlagship(){
        
        Flagship.sharedInstance.updateContext("Boolean_Key", true)
        Flagship.sharedInstance.updateContext("String_Key", "june")
        Flagship.sharedInstance.updateContext("Number_Key", 200)


        Flagship.sharedInstance.activateModification(key: "")

        let expectation = self.expectation(description: #function)
        
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "", visitorId:"zzz") { (result) in

            XCTAssert(result == .NotReady)
            
            Flagship.sharedInstance.activateModification(key: "btn-color")

            expectation.fulfill()
            
        }
        waitForExpectations(timeout: 10)
        
    }
    
    
    func testStartFlagshiWithWrongApiKey(){

        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng",apiKey:"ccc", visitorId:"") { (result) in

            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)

    }
    
    
    func testStartWithTimeout(){
        
        let expectation = self.expectation(description: #function)
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng",apiKey:"ccc", visitorId:"idUser",config: FSConfig(.DECISION_API, apiTimeout:2)) { (result) in
            
            /// the time out set from config is matching
            XCTAssert(Flagship.sharedInstance.service?.timeOutServiceForRequestApi == 2)
            /// the application wil not start
            XCTAssert(result == .NotReady)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
    }
    
    
 
    
    
    
    
    func testMockProtocol(){
        
         let apiURL = URL(string: "https://jsonplaceholder.typicode.com/posts/42")!
        
        let userID = 5
        let id = 42
        let title = "URLProtocol Post"
        let body = "Post body...."
        let jsonString = """
                         {
                            "userId": \(userID),
                            "id": \(id),
                            "title": "\(title)",
                            "body": "\(body)"
                         }
                         """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        let MockConfig = URLSessionConfiguration.default
        MockConfig.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration:MockConfig)
        
        let expectation = self.expectation(description: #function)
        
        session.dataTask(with: apiURL) { (data, response, error) in
            
            print("done")
             expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10)
         
    }
    
    
    

    
    
 
}
