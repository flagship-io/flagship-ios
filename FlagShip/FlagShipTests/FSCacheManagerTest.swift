//
//  FSCacheManagerTest.swift
//  FlagshipTests
//
//  Created by Adel on 28/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class FSCacheManagerTest: XCTestCase {

    var fsCacheMgr: FSCacheManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        fsCacheMgr = FSCacheManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testreadBucketFromCache() {

        let result = fsCacheMgr.readBucketFromCache()

        XCTAssertTrue( (result is FSBucket?) || (result == nil))
    }

    func testreadCampaignFromCache() {

        let result =  fsCacheMgr.readCampaignFromCache()

        XCTAssertTrue( result is  FSCampaigns?  || (result == nil) )
    }

    func testsaveBucketScriptInCache() {

        fsCacheMgr.saveBucketScriptInCache(nil)

        fsCacheMgr.saveBucketScriptInCache("mockToSave".data(using: .utf8))

    }

    func testsaveCampaignsInCache() {

        fsCacheMgr.saveCampaignsInCache(nil)

         fsCacheMgr.saveCampaignsInCache("mockToSave".data(using: .utf8))

    }

    func testcreateUrlForCache() {

        guard let resultUrl = fsCacheMgr.createUrlForCache() else { return  }

        do {
            try FileManager.default.removeItem(at: resultUrl)
        } catch {

        }

         let resultUrlBis = fsCacheMgr.createUrlForCache()

        XCTAssertTrue(resultUrlBis?.absoluteString.count != 0)
    }
}



