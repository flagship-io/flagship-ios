//
//  FSDataUsageTrackingTest.swift
//  FlagshipTests
//
//  Created by Adel Ferguen on 28/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

@testable import Flagship
import XCTest

class MockUsage: FSDataUsageTracking {
    override func sendTroubleshootingReport(_trHit: TroubleshootingHit) {
        print("overiding sendDataReport ")
    }
}

final class FSDataUsageTrackingTest: XCTestCase {
    override func setUpWithError() throws {
        var trTest: FSTroubleshooting
        
        let troubleshootingData = Data("""
        {
        "startDate": "2023-11-28T13:09:55.805Z",
        "endDate": "2023-11-29T01:09:55.805Z",
        "timezone": "UTC",
        "traffic": 100
        }
        """.utf8)
        
        let config: FlagshipConfig = FSConfigBuilder().build()
        
        do { trTest = try JSONDecoder().decode(FSTroubleshooting.self, from: troubleshootingData)
            FSDataUsageTracking.sharedInstance.configure(visitorId: "testTR", hasConsented: true, config: config, troubleshooting: trTest)
        }
        catch {}
    }
    
    /// Test Processing
    func testTimeSlotTr() {
        FSDataUsageTracking.sharedInstance._troubleshooting?.startDate = Date()
        FSDataUsageTracking.sharedInstance._troubleshooting?.endDate = Date().addingTimeInterval(1000)
        FSDataUsageTracking.sharedInstance.evaluateTroubleShootingConditions()
        XCTAssertTrue(FSDataUsageTracking.sharedInstance.troubleShootingReportAllowed)
        
        FSDataUsageTracking.sharedInstance._troubleshooting?.endDate = Date().addingTimeInterval(-100)
        FSDataUsageTracking.sharedInstance.evaluateTroubleShootingConditions()
        XCTAssertFalse(FSDataUsageTracking.sharedInstance.troubleShootingReportAllowed)
    }
    
    func testConsent() {
        let consentVisitor: FSVisitor = FSVisitorBuilder("consentUSer").hasConsented(hasConsented: false).build()
        FSDataUsageTracking.sharedInstance.configureWithVisitor(pVisitor: consentVisitor)
        XCTAssertFalse(FSDataUsageTracking.sharedInstance._hasConsented)
        consentVisitor.setConsent(hasConsented: true)
        XCTAssertTrue(FSDataUsageTracking.sharedInstance._hasConsented)
    }
    
    func testCreateCriticalFieldsForVisitor() {
        let config: FlagshipConfig = FSConfigBuilder().withTimeout(3000).withLogLevel(.ERROR).Bucketing().build()
        
        let consentVisitor: FSVisitor = FSVisitorBuilder("userTest").hasConsented(hasConsented: true).withContext(context: ["trCtx": "valCtx"]).build()
        
        consentVisitor.configManager.flagshipConfig = config
        FSDataUsageTracking.sharedInstance.configureWithVisitor(pVisitor: consentVisitor)
        let variation = FSVariation(idVariation: "varId", variationName: "varName", nil, isReference: true)
        let camp = FSCampaign("cmp1", "cmpName", "varGrpId", "nameGrp", "ab", "slug")
        consentVisitor.currentFlags = ["flagTR": FSModification(aCampaign: camp, aVariation: variation, valueForFlag: 12)]
        let ret: [String: String] = FSDataUsageTracking.sharedInstance.createCriticalFieldsForVisitor(consentVisitor)
        
        XCTAssertTrue(ret.keys.contains("visitor.flags.[flagTR].key"))
        XCTAssertTrue(ret.keys.contains("visitor.flags.[flagTR].value"))
        XCTAssertTrue((ret["visitor.flags.[flagTR].key"] ?? "") == "flagTR")
        XCTAssertTrue((ret["visitor.flags.[flagTR].value"] ?? "") == "12")
        XCTAssertTrue((ret["sdk.config.mode"] ?? "") == "BUCKETING")
        XCTAssertTrue((ret["sdk.config.trackingManager.strategy"] ?? "") == "CONTINUOUS_CACHING")
        XCTAssertTrue((ret["visitor.context.[trCtx]"] ?? "") == "valCtx")
        XCTAssertTrue((ret["sdk.config.timeout"] ?? "") == "3000")
    }
    
    func testCreateCrticalXpc() {
        let xpcVisitor: FSVisitor = FSVisitorBuilder("userXpcTest").hasConsented(hasConsented: true).withContext(context: ["trCtx": "valCtx"]).build()
        xpcVisitor.configManager.flagshipConfig = FSConfigBuilder().build()
        xpcVisitor.authenticate(visitorId: "loggedId")
        FSDataUsageTracking.sharedInstance.configureWithVisitor(pVisitor: xpcVisitor)
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_AUTHENTICATE.rawValue, visitor: xpcVisitor)
        XCTAssertTrue(FSDataUsageTracking.sharedInstance._visitorId == "loggedId")
    }
    
    func testCreateCriticalFieldsHits() {
        let ret: [String: String] = FSDataUsageTracking.sharedInstance.createCriticalFieldsHits(hit: FSScreen("TRScreen"))
        XCTAssertEqual(ret["hit.dl"], "TRScreen")
    }
    
    func testStressTroubleshooting() {
        for i in 1 ... 100 {
            let testVisitor: FSVisitor = FSVisitorBuilder("userXpcTest\(i)").hasConsented(hasConsented: true).withContext(context: ["trCtx": "valCtx"]).build()
            testVisitor.configManager.flagshipConfig = FSConfigBuilder().build()
            FSDataUsageTracking.sharedInstance.processTSFetching(v: testVisitor, campaigns: nil, fetchingDate: Date())
            FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: CriticalPoints.GET_FLAG_VALUE_FLAG_NOT_FOUND, f: FSFlag("key", nil, "defaultValue", nil), v: testVisitor)
            FSDataUsageTracking.sharedInstance.proceesTSFlag(crticalPointLabel: CriticalPoints.GET_FLAG_VALUE_FLAG_NOT_FOUND, f: FSFlag("key", nil, "defaultValue", nil), v: nil)
            FSDataUsageTracking.sharedInstance.processTSHits(label: "label", visitor: testVisitor, hit: FSScreen("TRScreen\(i)"))
            FSDataUsageTracking.sharedInstance.processTSXPC(label: "label", visitor: testVisitor)
            FSDataUsageTracking.sharedInstance.processTSBucketingFile(HTTPURLResponse(url: URL(string: "testUrl")!, statusCode: 200, httpVersion: nil, headerFields: nil), URLRequest(url: URL(string: "testUrl")!), Data())
            FSDataUsageTracking.sharedInstance.processTSHttp(crticalPointLabel: CriticalPoints.HTTP_CALL, nil, URLRequest(url: URL(string: "testUrl")!), nil)
            FSDataUsageTracking.sharedInstance.processTSHttpError(requestType: .Campaign, nil, URLRequest(url: URL(string: "testUrl")!), nil)
            FSDataUsageTracking.sharedInstance.processTSCatchedError(v: nil, error: FlagshipError(message: "error"))
        }
    }
    
    func testDeveloperUsage() {
        let config: FlagshipConfig = FSConfigBuilder().withDisableDeveloperUsageTracking(true).build()
        let devUsageVisitor: FSVisitor = FSVisitorBuilder("user23").hasConsented(hasConsented: true).withContext(context: ["trCtx": "valCtx"]).build()
        devUsageVisitor.configManager.flagshipConfig = FSConfigBuilder().build()
        devUsageVisitor.configManager.flagshipConfig = config
        
        FSDataUsageTracking.sharedInstance.configureWithVisitor(pVisitor: devUsageVisitor)
        XCTAssertFalse(FSDataUsageTracking.sharedInstance.dataUsageTrackingReportAllowed)

        config.disableDeveloperUsageTracking = false
        FSDataUsageTracking.sharedInstance.dataUsageTrackingReportAllowed = true
        XCTAssertTrue(FSDataUsageTracking.sharedInstance.dataUsageTrackingReportAllowed)
    }
    
    func testTroubleshootingHit() {
        Flagship.sharedInstance.start(envId: "gk87t3jggr10c6l6sdob", apiKey: "trApiKey")
        Flagship.sharedInstance.newVisitor("truser").build()
        let trHit = TroubleshootingHit(pVisitorId: "trId", pLabel: "trLabel", pSpeceficCustomFields: ["key1": "val1"])
        let bodyTr: [String: Any] = trHit.bodyTrack
        XCTAssertTrue(bodyTr["vid"] as? String == "trId")
        XCTAssertTrue(bodyTr["t"] as? String == "TROUBLESHOOTING")
        
        XCTAssertTrue(bodyTr["cv"] is [String: String])
        
        if let cv: [String: String] = bodyTr["cv"] as? [String: String] {
            XCTAssertTrue(cv["label"] == "trLabel")
        }
        
        let duHit = FSDataUsageHit(pVisitorId: "duId", pLabel: "duLabel", pSpeceficCustomFields: ["key1": "val1"])
        let bodyDu: [String: Any] = duHit.bodyTrack
        XCTAssertTrue(bodyDu["t"] as? String == "USAGE")
    }
}
