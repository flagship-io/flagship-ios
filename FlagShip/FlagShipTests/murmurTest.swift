//
//  murmurTest.swift
//  FlagshipTests
//
//  Created by Adel on 27/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class murmurTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
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

    
    func testHash(){
        
        if let arrayUsers:[String] =  getUserIdMock() {
            
            print("Will test MurMurHash for 100 users ...")
            XCTAssert(arrayUsers.count == 100)
            
            for visitorId:String in arrayUsers {
                
                if let alloc =  arrayUsers.firstIndex(of: visitorId){  /// The alloc correspond to index in array 
                    
                let hashAlloc = (Int(MurmurHash3.hash32(key: visitorId) % 100))
                    
                    print("if \(alloc) is Equal To \(hashAlloc) ")
                    
                    XCTAssert(alloc == hashAlloc )
                }
            }
        }
    }
    
    /// get the users id
     internal func getUserIdMock() -> [String]?{
        
        do {
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "usersId", withExtension: "json") else { return nil }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            if let jsonResult:NSDictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary{
                
                if let userId : [String] = jsonResult ["usersId"] as? [String] {
                    
                    return userId
                }
            }
        }catch{
            
            print("error")
            return nil
        }
        return nil
    }
    
    
    
    
}
