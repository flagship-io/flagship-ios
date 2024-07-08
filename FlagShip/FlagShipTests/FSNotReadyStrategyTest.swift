//
//  FSNotReadyStrategyTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 09/06/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

final class FSNotReadyStrategyTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNotReadySdk() {
        Flagship.sharedInstance.start(envId: "notReady", apiKey: "apikey")

        let userNR = Flagship.sharedInstance.newVisitor(visitorId: "userNR", hasConsented: true).build()

        userNR.updateContext(["a": "b"])
        userNR.fetchFlags {}
        // Update Context
        let lengthCtx = userNR.getContext().count
        userNR.strategy?.getStrategy().updateContext(["a": "b"])
        XCTAssertEqual(userNR.getContext().count, lengthCtx)
        // Get Falg
        XCTAssertEqual(userNR.strategy?.getStrategy().getModification("keyNR", defaultValue: "dfl_NR"), "dfl_NR")
        // Get Flag Modification
        XCTAssertNil(userNR.strategy?.getStrategy().getFlagModification("keyNR"))
        // Get Modification inofs
        XCTAssertNil(userNR.strategy?.getStrategy().getFlagModification("keyNR"))
        // Send Hit
        userNR.strategy?.getStrategy().sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "eventNR"))

        userNR.strategy?.getStrategy().cacheVisitor()
    }
}
