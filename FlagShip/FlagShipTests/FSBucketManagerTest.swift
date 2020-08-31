//
//  FSBucketManagerTest.swift
//  FlagshipTests
//
//  Created by Adel on 20/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSBucketManagerTest: XCTestCase {
    
    var bucketManager:FSBucketManager = FSBucketManager()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSelectVariationWithHashMurMur(){
        
        /// read the data from the file and fill the campaigns
        do {
            
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            let bucketObject = try JSONDecoder().decode(FSBucket.self, from: data)
            
            
            Flagship.sharedInstance.visitorId = "alias"   /// Visitor id

            Flagship.sharedInstance.updateContext("basketNumber", 100) /// belong to first group
            
            Flagship.sharedInstance.updateContext("basketNumberBis", 200)  /// belong to second group
            
            Flagship.sharedInstance.visitorId = "alias"

            let camps = bucketManager.bucketVariations("alias", bucketObject)
            

            if let varGroup = bucketObject.campaigns.first?.variationGroups{
                
                for item:FSVariationGroup in varGroup {
                    
                    let ret = bucketManager.selectVariationWithHashMurMur("alias", item, true)
                }
            }
            
        }catch{
            
            print("error")
        }

        
        
        
        
        
    }

}
