//
//  FSStorageTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 07/06/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSStorageTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSavingBucketing() {
        do {
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else {
                return
            }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            FSStorageManager.saveBucketScriptInCache(data)

        } catch {
            return
        }
    }

    func testReadBucketing() {
        if let savedBucket = FSStorageManager.readBucketFromCache() {
            XCTAssertTrue(savedBucket.campaigns.count ==  4)
            XCTAssertTrue(savedBucket.panic == false)
        }
    }
}
