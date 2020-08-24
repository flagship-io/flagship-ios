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
    
    
    

}
