//
//  MurmurTest.swift
//  FlagshipTests
//
//  Created by Adel on 27/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import XCTest
@testable import Flagship

class MurmurTest: XCTestCase {

    /// See the file  https://docs.google.com/spreadsheets/d/1WOWyr7KBo9fN4SVKVqTvmwhmQhSZDMnkHQSlSoH_Acs/edit#gid=491574280
    let sampleIds: [Sample] = [
        // 202072017183814142    1    4    ok
        Sample("202072017183814142", pAlloc50: 1, pAlloc25: 4),

        // 202072017183860649    1    1    ok
        Sample("202072017183860649", pAlloc50: 1, pAlloc25: 1),

        // 202072017183828850    1    2    ok
        Sample("202072017183828850", pAlloc50: 1, pAlloc25: 2),

        // 202072017183818733    1    4    ok
        Sample("202072017183818733", pAlloc50: 1, pAlloc25: 4),
        // 202072017183823773    2    2    ok
        Sample("202072017183823773", pAlloc50: 2, pAlloc25: 2),

        // 202072017183894922    1    4    ok
        Sample("202072017183894922", pAlloc50: 1, pAlloc25: 4),

        // 202072017183829817    1    1    ok
        Sample("202072017183829817", pAlloc50: 1, pAlloc25: 1),

        // 202072017183842202    1    3    ok
        Sample("202072017183842202", pAlloc50: 1, pAlloc25: 3),

        // 202072017233645009    2    2    ok
        Sample("202072017233645009", pAlloc50: 2, pAlloc25: 2),

        // 202072017233690230    2    1    ok
        Sample("202072017233690230", pAlloc50: 2, pAlloc25: 1),

        // 202072017183886606    1    4    ok
        Sample("202072017183886606", pAlloc50: 1, pAlloc25: 4),

        // 202072017183877657    1    4    ok
        Sample("202072017183877657", pAlloc50: 1, pAlloc25: 4),

        // 202072017183860380    1    1    ok
        Sample("202072017183860380", pAlloc50: 1, pAlloc25: 1),

        // 202072017183972690    2    1    ok
        Sample("202072017183972690", pAlloc50: 2, pAlloc25: 1),

        // 202072017183912618    1    2    ok
        Sample("202072017183912618", pAlloc50: 1, pAlloc25: 2),

        // 202072017183951364    1    3    ok
        Sample("202072017183951364", pAlloc50: 1, pAlloc25: 3),

        // 202072017183920657    2    4    ok
        Sample("202072017183920657", pAlloc50: 2, pAlloc25: 4),

        // 202072017183922748    2    1    ok
        Sample("202072017183922748", pAlloc50: 2, pAlloc25: 1),

        // 202072017183943575    1    3    ok
        Sample("202072017183943575", pAlloc50: 1, pAlloc25: 3),

        // 202072017183987677    1    4    ok
        Sample("202072017183987677", pAlloc50: 1, pAlloc25: 4)
    ]

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

 

    func testHash() {

        if let arrayUsers: [String] =  getUserIdMock() {

            print("Will test MurMurHash for 100 users ...")
            XCTAssert(arrayUsers.count == 100)

            for visitorId: String in arrayUsers {

                if let alloc =  arrayUsers.firstIndex(of: visitorId) {  /// The alloc correspond to index in array 

                let hashAlloc = (Int(MurmurHash3.hash32(key: visitorId) % 100))

                    print("if \(alloc) is Equal To \(hashAlloc) ")

                    XCTAssert(alloc == hashAlloc )
                }
            }
        }
    }

    /// get the users id
     internal func getUserIdMock() -> [String]? {

        do {
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "usersId", withExtension: "json") else { return nil }

            let data = try Data(contentsOf: path, options: .alwaysMapped)

            if let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? NSDictionary {

                if let userId: [String] = jsonResult ["usersId"] as? [String] {

                    return userId
                }
            }
        } catch {

            print("error")
            return nil
        }
        return nil
    }

    func testDistributionMurMurHash() {

        if let lightBucketObject = getLightMock("lightBucketMock") {

            var variationA: Double = 0
            var variationB: Double = 0
            /// To fit the targeting for all userss
          //  Flagship.sharedInstance.updateContext(ALL_USERS, "")

            /// Will test for 10 000 users
            let max: Int = 1000
            for index in 1...max {

                print("Test distribution MurMurHash number : \(index)")

                let idToTesst = FSGenerator.generateFlagShipId()

                print("Test distribution for id : \(idToTesst)")
                let service = FSService("", "", "", nil)
                let bucketMgr:FSBucketingManager = FSBucketingManager(service:service, userId: idToTesst, currentContext: [ALL_USERS : ""], 60)
                
                    let bucketCache =  bucketMgr.matchTargetingForCustomID(lightBucketObject, idToTesst)

                // Check wich variation we got :

                if let testCamp = bucketCache.getCampaignArray().first {

                   // Check the Id

                    if  testCamp.variation?.idVariation == "bqso7p5tl9jg05d8033g" {
                        variationA += 1
                    } else if  testCamp.variation?.idVariation == "bqso7p5tl9jg05d80340" {
                        variationB += 1

                    } else {
                        print(" ouuuups Shouldn't happen")
                        XCTAssert(false)
                    }
                }

            }

            print("Number of variation for Variation A is : \(variationA) For \(max) users")

            print("Number of variation for Variation B is : \(variationB) For \(max) users")

            /// un peu de stat

            let delta = abs(variationA - variationB)

            print("Delta between variations is  \(delta)")

            let  percentA: Double = (variationA / Double(max))*100
            let  percentB: Double = (variationB / Double(max))*100

            print("pourcent of variation A is \(percentA)")

            print("pourcent of variation B is \(percentB)")

            XCTAssert((variationA + variationB) == Double(max))
        }
    }

    func testSampleIdMock() {

        var modifsValuesMock: [String: Any] = [:]

        if let sampleBucket = getLightMock("sampleIdBucket") {


            for item: Sample in sampleIds {

                modifsValuesMock.removeAll()
                let service = FSService("", "", "", nil)
                let bucketMgr:FSBucketingManager = FSBucketingManager(service:service, userId: item.idSample, currentContext: [ALL_USERS : ""], 60)

                let sampleBucketCache = bucketMgr.matchTargetingForCustomID(sampleBucket, item.idSample)

                /// preced to check the results

                for itemCamp: FSCampaignCache in sampleBucketCache.campaigns {

                    for itemVarGroup in itemCamp.variationGroups {

                        if let modif = itemVarGroup.variation.modification {

                            if let values = modif.value {

                                modifsValuesMock.merge(values) {(_, new) in new }

                            }
                        }
                    }

                }

                /// Check the values for Alloc 25
                if let variation = modifsValuesMock["variation"] as? Int {

                    XCTAssertEqual(variation, item.alloc25)

                } else {

                    XCTAssert(false)
                }
                /// Check alloc for values 50
                if let variation50 = modifsValuesMock["variation50"] as? Int {

                      XCTAssertEqual(variation50, item.alloc50)

                } else {

                    XCTAssert(false)

                }
            }
        }
    }

//// Get light mock

    func getLightMock(_ fileName: String) -> FSBucket? {

    do {
         let testBundle = Bundle(for: type(of: self))

         guard let path = testBundle.url(forResource: fileName, withExtension: "json") else { return nil }

         let data = try Data(contentsOf: path, options: .alwaysMapped)

         let lightBucketObject = try JSONDecoder().decode(FSBucket.self, from: data)

        return lightBucketObject
     } catch {

         print("error")
         return nil
     }
}

}

struct Sample {

    let idSample: String
    let alloc50: Int
    let alloc25: Int

    init(_ idSample: String, pAlloc50: Int, pAlloc25: Int) {

        self.idSample = idSample

        self.alloc25 = pAlloc25

        self.alloc50 = pAlloc50
    }

}
