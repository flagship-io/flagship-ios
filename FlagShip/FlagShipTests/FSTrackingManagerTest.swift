//
//  FSTrackingManagerTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 07/06/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSTrackingManagerTest: XCTestCase {
    var trackingManager: FSTrackingManager?
    var perdiodicTrackingManager: PeriodicTrackingManager?

    var fsTestCacheManager: FSTestCacheManager = .init()

    let testEvent = FSEvent(eventCategory: .Action_Tracking, eventAction: "testEvent")

    override func setUpWithError() throws {
        /// Fake session
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlFakeSession = URLSession(configuration: configuration)

        // Put setup code here. This method is called before the invocation of each test method in the class.
        let service = FSService("envID", "apiKey", "vid")
        service.serviceSession = urlFakeSession
        let configTracking = FSTrackingConfig()
        trackingManager = FSTrackingManager(service, configTracking, FSCacheManager())

        let fsCacheManager = FSCacheManager(nil, fsTestCacheManager, visitorLookupTimeOut: 0.2, hitCacheLookupTimeout: 0.2)
        perdiodicTrackingManager = PeriodicTrackingManager(service, configTracking, fsCacheManager)

        // Set up the event
        testEvent.visitorId = "testUser"
        testEvent.envId = "envId"
    }

    func testSendHitWithSucess() {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        trackingManager?.sendHit(testEvent)
        sleep(1)
        XCTAssertTrue(trackingManager?.failedIds.isEmpty == true)
    }

    func testSendHitWithFailed() {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        trackingManager?.sendHit(testEvent)

        sleep(1)

        XCTAssertTrue(trackingManager?.failedIds.isEmpty == false)
    }

    func testAddTrackingElementsToBatch() {
        // Test the activate
        let activateTest = Activate("vid", nil, modification: FSModification(campId: "campId", varGroupId: "groupId", varId: "varId", typeOfTest: "AB", aSlug: "slug", val: 12))
        XCTAssertTrue(activateTest.description().count > 0)

        trackingManager?.addTrackingElementsToBatch([
            FSEvent(eventCategory: .Action_Tracking, eventAction: "test"),
            FSEvent(eventCategory: .User_Engagement, eventAction: "test"), activateTest

        ])
    }

    /// Perdiodic Strategy tesitng

    func testPerdiodicSendHit() {
        perdiodicTrackingManager?.sendHit(testEvent)
        XCTAssert(perdiodicTrackingManager?.batchManager.isQueueEmpty() == false)
    }

    func testOnSucessToSendHits() {
        let batchTest = FSBatch([testEvent, testEvent, testEvent])

        perdiodicTrackingManager?.batchManager.reInjectElements(listToReInject: [testEvent, testEvent, testEvent])
        perdiodicTrackingManager?.onSucessToSendHits(batchTest)
        XCTAssertTrue(fsTestCacheManager.isCacheHitsCalled == true)
    }

    func testonFailedToSendHits() {
        fsTestCacheManager.isCacheHitsCalled = false
        let batchTest = FSBatch([testEvent, testEvent, testEvent])
        perdiodicTrackingManager?.onFailedToSendHits(batchTest)
        XCTAssertTrue(fsTestCacheManager.isCacheHitsCalled == true)
    }

    func testFlushTrackAndKeepConsent() {
        perdiodicTrackingManager?.flushTrackAndKeepConsent("testUser")
        XCTAssertTrue(fsTestCacheManager.isFlushHitsCalled == true)
    }
}
