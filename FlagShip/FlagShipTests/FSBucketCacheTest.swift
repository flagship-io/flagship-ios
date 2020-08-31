//
//  FSBucketCacheTest.swift
//  FlagshipTests
//
//  Created by Adel on 01/04/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship



class FSBucketCacheTest: XCTestCase {

    
    
    var bucketCache: FSBucketCache!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
         bucketCache = FSBucketCache("userId")
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
         bucketCache = nil
    }

 
     
 
    
    
    func testGetCampaignnilArray(){
        
        bucketCache.campaigns = nil
        XCTAssertTrue(self.bucketCache.getCampaignArray().count == 0)

    }
    
    
    func testGetCampaignEmptyArray(){
        
        bucketCache.campaigns = []
        XCTAssertTrue(self.bucketCache.getCampaignArray().count == 0)

    }
    
    
    func testGetCampaignyArray(){
        
        
            
        bucketCache.campaigns = [FSCampaignCache("idC", [FSVariationGroupCache("idG", FSVariationCache("idv"))]),
                                 FSCampaignCache("idC", [FSVariationGroupCache("idG", FSVariationCache("idv"))]),
                                 FSCampaignCache("idC", [FSVariationGroupCache("idG", FSVariationCache("idv"))]),
                                 FSCampaignCache("idC", [FSVariationGroupCache("idG", FSVariationCache("idv"))]),
                                 FSCampaignCache("idC", [FSVariationGroupCache("idG", FSVariationCache("idv"))])]
        
        XCTAssertTrue(self.bucketCache.getCampaignArray().count == 5)

    }
    
    
    
    func testSaveMe(){
        
        self.bucketCache.saveMe()
    }
    
    
    
    func testFSBucketCache(){
        do {
             let testBundle = Bundle(for: type(of: self))

             guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else {
                
                return
            }
             
             let data = try Data(contentsOf: path, options:.alwaysMapped)
             
             let bucketCache = try JSONDecoder().decode(FSBucketCache.self, from: data)
            
            
            XCTAssert(bucketCache.visitorId  == "error" )
            XCTAssert(bucketCache.campaigns.count  == 4 )
            
            print(bucketCache)
            
          
         }catch{
             
             print("error")
             return
         }
    }
    
    
    func testFSBucket(){
        let bucket = FSBucket()
        XCTAssertTrue(bucket.panic == true)
        XCTAssertTrue(bucket.campaigns.count == 0)
    }

}
