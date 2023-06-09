//
//  FSHitTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 08/06/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSHitTest: XCTestCase {
    var listOfContent: [[String: Any]] = []
    var listOfActivate: [[String: Any]] = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        do {
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "content_hit", withExtension: "json") else {
                return
            }

            guard let pathActivate = testBundle.url(forResource: "content_activate", withExtension: "json") else {
                return
            }

            let data = try Data(contentsOf: path, options: .alwaysMapped)
            let dataActivate = try Data(contentsOf: pathActivate, options: .alwaysMapped)

            listOfContent = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
            listOfActivate = try JSONSerialization.jsonObject(with: dataActivate) as? [[String: Any]] ?? []

        } catch {
            print("---------------- Failed to load the buckeMock file ----------")
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testModelHit() {
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdhdf", apiKey: "apikey")
        let testVisiteur = Flagship.sharedInstance.newVisitor("userTest").build()

        let pageTest = FSPage("testLocation")
        let screenTest = FSScreen("screenLocationTest")
        let eventTest = FSEvent(eventCategory: .Action_Tracking, eventAction: "testEvent")
        let eventTestBis = FSEvent(eventCategory: .User_Engagement, eventAction: "testEventBis")
        let transactionTest = FSTransaction(transactionId: "idTransac", affiliation: "trasancTest")
        let itemTest = FSItem(transactionId: "idItem", name: "nameItem", code: "codeItem")

        let eventList: [FSTracking] = [pageTest, screenTest, eventTest, eventTestBis, transactionTest, itemTest]
        // Set the visitorId and envId
        for itemEvent: FSTracking in eventList {
            itemEvent.visitorId = "userTest"
            itemEvent.envId = "bkk9glocmjcg0vtmdhdf"
            itemEvent.userIp = "ipTest"
            itemEvent.userLanguage = "lngTest"
            itemEvent.screenResolution = "srTest"
            itemEvent.sessionNumber = 12
            itemEvent.createdAt = 1222

            // Body Track
            XCTAssertTrue(itemEvent.bodyTrack["vid"] as? String == "userTest")
            XCTAssertTrue(itemEvent.bodyTrack["cid"] as? String == "bkk9glocmjcg0vtmdhdf")
            XCTAssertTrue(itemEvent.bodyTrack["uip"] as? String == "ipTest")
            XCTAssertTrue(itemEvent.bodyTrack["sr"] as? String == "srTest")
            XCTAssertTrue(itemEvent.bodyTrack["sn"] as? Int == 12)
            let qt = Date().timeIntervalSince1970 - 1222
            XCTAssertTrue(itemEvent.bodyTrack["qt"] as? Double == qt.rounded())
        }
    }

    func testWithDecode() {
        for itemContent in listOfContent {
            var typeOfHit = ""

            if let data = itemContent["data"] as? [String: Any] {
                if let content = data["content"] as? [String: Any] {
                    typeOfHit = content["t"] as! String

                    do {
                        let newHit: FSTrackingProtocol
                        let decoder = JSONDecoder()
                        let jsonData = try JSONSerialization.data(withJSONObject: content)
                        switch typeOfHit {
                        case "SCREENVIEW":
                            newHit = try decoder.decode(FSScreen.self, from: jsonData)
                            XCTAssertTrue(newHit.bodyTrack["dl"] as? String == "screen")
                        case "PAGEVIEW":
                            newHit = try decoder.decode(FSPage.self, from: jsonData)
                            XCTAssertTrue(newHit.bodyTrack["dl"] as? String == "pageView")
                        case "EVENT":
                            newHit = try decoder.decode(FSEvent.self, from: jsonData)
                        case "TRANSACTION":
                            newHit = try decoder.decode(FSTransaction.self, from: jsonData)
                            XCTAssertTrue(newHit.bodyTrack["tc"] as? String == "euro")
                        case "ITEM":
                            newHit = try decoder.decode(FSItem.self, from: jsonData)
                            XCTAssertTrue(newHit.bodyTrack["ic"] as? String == "codeItem")
                        case "ACTIVATE":
                            newHit = try decoder.decode(Activate.self, from: jsonData)
                            XCTAssertTrue(newHit.bodyTrack["caid"] as? String == "chsrcv6e4nsic4ug2p0g")

                        default:
                            break
                        }
                    } catch {}
                }
            }
        }
    }

    func testWithActivate() {
        for itemContent in listOfActivate {
            if let data = itemContent["data"] as? [String: Any] {
                if let content = data["content"] as? [String: Any] {
                    do {
                        let newHit: FSTrackingProtocol
                        let decoder = JSONDecoder()
                        let jsonData = try JSONSerialization.data(withJSONObject: content)

                        newHit = try decoder.decode(Activate.self, from: jsonData)
                        XCTAssertTrue(newHit.bodyTrack["caid"] as? String == "chsrcv6e4nsic4ug2p0g")

                    } catch {}
                }
            }
        }
    }
}
