//
//  FSTroubleshooting.swift
//  Flagship
//
//  Created by Adel Ferguen on 13/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

// Allocation threshold for data usage tracking
let FSDataUsageAllocationThreshold = 1
 
 

class FSDataUsageTracking {
    var visitorSessionId: String = FSTools.generateUuidv4()

    // Trouble shooting
    var _troubleshooting: FSTroubleshooting?
    // Visitor Id
    var _visitorId: String = ""
    // Has the visitor consented
    var _hasConsented: Bool = true
    // Config SDK
    var _sdkConfig: FlagshipConfig?
    // Instance for visitor
    var _visitorSessionId: String // relative to session creation
    // Service to send report
    var _service: FSService?
    // Is the Troubleshooting is allowed
    var troubleShootingReportAllowed: Bool = false
    // Is Data Usage is allowed
    var dataUsageTrackingReportAllowed: Bool = true

    // Shared instace
    static let sharedInstance: FSDataUsageTracking = {
        let instance = FSDataUsageTracking()
        // setup code
        return instance
    }()

    private init() {
        _service = FSService(Flagship.sharedInstance.envId ?? "", Flagship.sharedInstance.apiKey ?? "", _visitorId, nil)
        _visitorSessionId = FSTools.generateUuidv4()
    }

    // Configure with params
    func configure(visitorId: String, hasConsented: Bool, config: FlagshipConfig, troubleshooting: FSTroubleshooting) {
        _visitorId = visitorId
        _hasConsented = hasConsented
        _sdkConfig = config
        _troubleshooting = troubleshooting
        _service?.visitorId = visitorId
        evaluateDataUsageTrackingAllocated()
    }

    // Configure with visitor instance
    func configureWithVisitor(pVisitor: FSVisitor) {
        _visitorId = pVisitor.visitorId
        _hasConsented = pVisitor.hasConsented
        _sdkConfig = pVisitor.configManager.flagshipConfig
        _service?.visitorId = pVisitor.visitorId
        evaluateDataUsageTrackingAllocated()
    }

    // Update Troubleshootings settings
    func updateTroubleshooting(trblShooting: FSTroubleshooting?) {
        _troubleshooting = trblShooting
        // Re evaluate the conditions of data usage tracking
        evaluateTroubleShootingConditions()
    }

    func isVisitorHasConsented() -> Bool {
        return _hasConsented
    }

    // Update the consent
    func updateConsent(newValue: Bool) {
        _hasConsented = newValue
        evaluateTroubleShootingConditions()
    }

    // Send Troubleshooting Report
    func sendTroubleshootingReport(_trHit: TroubleshootingHit) {
        if troubleShootingReportAllowed {
            sendDataReport(_trHit)
        }
    }

    // Send the data usage tracking
    func sendDataUsageReport(_duHit: FSDataUsageHit) {
        if dataUsageTrackingReportAllowed {
            sendDataReport(_duHit)
        } else {
            FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Sending developer data usage not allowed"))
        }
    }
}
