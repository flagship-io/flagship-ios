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
        let configTracking = FSTrackingManagerConfig()
        trackingManager = FSTrackingManager(service, configTracking, FSCacheManager())

        let fsCacheManager = FSCacheManager(nil, fsTestCacheManager, visitorLookupTimeOut: 0.2, hitCacheLookupTimeout: 0.2)
        perdiodicTrackingManager = PeriodicTrackingManager(service, configTracking, fsCacheManager)

        // Set up the event
        testEvent.visitorId = "testUser"
        testEvent.envId = "envId"
    }

    func testSendHitWithSuccess() {
        let expectationSync = XCTestExpectation(description: "testSendHitWithSuccess")

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        trackingManager?.sendHit(testEvent)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertTrue(self.trackingManager?.failedIds.isEmpty == true)
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 6.0)
        
    }

    func testSendHitWithFailed() {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "---")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }

        let expectationSync = XCTestExpectation(description: "testSendHitWithFailed")

        trackingManager?.sendHit(testEvent)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertTrue(self.trackingManager?.failedIds.isEmpty == false)
            expectationSync.fulfill()
        }
        wait(for: [expectationSync], timeout: 6.0)
    }

    func testAddTrackingElementsToBatch() {
        // Create FSModification

        let camp = FSCampaign("campId", "campName", "groupId", "groupName", "A/B", "slugg")

        let variation = FSVariation(idVariation: "varId", variationName: "varName", nil, isReference: false)

        let modif = FSModification(aCampaign: camp, aVariation: variation, valueForFlag: 12)

        // Test the activate
        let activateTest = Activate("vid", nil, modification: modif)
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

    func testOnSuccessToSendHits() {
        let batchTest = FSBatch([testEvent, testEvent, testEvent])

        perdiodicTrackingManager?.batchManager.reInjectElements(listToReInject: [testEvent, testEvent, testEvent])
        perdiodicTrackingManager?.onSuccessToSendHits(batchTest)
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
