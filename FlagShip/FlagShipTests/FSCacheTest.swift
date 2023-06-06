//
//  FSCacheTest.swift
//  FlagshipTests
//
//  Created by Adel on 15/09/2022.
//  Copyright © 2022 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSCacheTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testCacheHitClass(){
        
        // decode the array of data
        let decoder = JSONDecoder()
        do {
            let testBundle = Bundle(for: type(of: self))
            
            guard let path = testBundle.url(forResource: "hitCache", withExtension: "json") else {
                return
            }
            
            let data = try Data(contentsOf: path, options: .alwaysMapped)
            let cachedHit = try decoder.decode(FSCacheHit.self, from: data)

            XCTAssert(cachedHit.version == 2)
            XCTAssert(cachedHit.data?.visitorId == "visitor_1")
            XCTAssert(cachedHit.data?.anonymousId == "anonym_0")
            XCTAssert(cachedHit.data?.type == "screen")
            XCTAssert(cachedHit.data?.time == 0.0)
            XCTAssert(cachedHit.data?.content.count == 0)
            XCTAssertTrue(cachedHit.data?.numberOfBytes == 4)

            XCTAssertFalse(cachedHit.isLessThan4Hours())
            
            /// encode
            let coder = JSONEncoder()

            let resultEncoder = try coder.encode(cachedHit)
            
            let ret = try JSONSerialization.jsonObject(with: resultEncoder)
            
            if let dico = ret as? [String:Any]{
                
                XCTAssertTrue(dico["version"] as? Int == 2)
            }
        } catch {
            print(error)
        }
    }
    
    
//    
//    func testWithinit(){
//        let ch1 = FSCacheHit.init(visitorId: "v1", anonymousId: "a1", type: "event", bodyTrack: ["a":"b"])
//        XCTAssertTrue(ch1.data?.visitorId == "v1")
//        XCTAssertTrue(ch1.data?.anonymousId == "a1")
//        XCTAssertTrue(ch1.data?.type == "event")
//        XCTAssertTrue(ch1.data?.content.count == 1)
//    }

    
        
 

}
