//
//  FSTroubleshooting.swift
//  Flagship
//
//  Created by Adel Ferguen on 13/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class FSDataUsageTracking {
    var visitorSessionId: String = FSTools.generateUuidv4()
    
    var _troubleshooting: FSTroubleshooting?
    var _visitorId: String = ""
    var _hasConsented: Bool = true
    var _sdkConfig: FlagshipConfig?
    
    var _visitorSessionId: String // relative to session creation

    var _service: FSService?
    
    var troubleShootingReportAllowed: Bool = false

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
    
    func configure(visitorId: String, hasConsented: Bool, config: FlagshipConfig, troubleshooting: FSTroubleshooting) {
        _visitorId = visitorId
        _hasConsented = hasConsented
        _sdkConfig = config
        _troubleshooting = troubleshooting
        _service?.visitorId = visitorId
    }
    
    func configureWithVisitor(pVisitor: FSVisitor) {
        _visitorId = pVisitor.visitorId
        _hasConsented = pVisitor.hasConsented
        _sdkConfig = pVisitor.configManager.flagshipConfig
        _service?.visitorId = pVisitor.visitorId
    }
    
    func updateTroubleshooting(trblShooting: FSTroubleshooting?) {
        _troubleshooting = trblShooting
        // Re evaluate the conditions of datausagetracking
        evaluateTroubleShootingConditions()
    }
    
    // Evaluate conditions to allow TS (trouble shooting) reporting
    func evaluateTroubleShootingConditions() {
        // To allow the dataUsageTracking we have to check
        troubleShootingReportAllowed = isTimeSlotValide() && // TimeSlot

            isBucketTroubleshootingAllocated() && // Bucket Allocation for TR

            isVisitorHasConsented() // Visitor Consent

        if troubleShootingReportAllowed {
            FlagshipLogManager.Log(level: FSLevel.ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("-------------- Troubleshooting Allowed ✅✅✅✅✅ ---------------"))
        } else {
            FlagshipLogManager.Log(level: FSLevel.ALL, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("-------------- Trouble shooting NOT Allowed ❌❌❌❌❌ --------------"))
        }
    }
    
    func isTimeSlotValide()->Bool {
        if let startDate = _troubleshooting?.startDate {
            if let endDate = _troubleshooting?.endDate {
                let actualDate = Date()
                if (actualDate > startDate) && (actualDate < endDate) {
                    return true
                }
            }
        }
        return false
    }
    
    func isBucketTroubleshootingAllocated()->Bool {
        // Calculate the bucket allocation
        if _troubleshooting?.endDateString != nil {
            let combinedId: String = _visitorId + (_troubleshooting?.endDateString ?? "")
            
            let hashAlloc = Int(MurmurHash3.hash32(key: combinedId) % 100)
            
            FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("The hash allocation for TR bucket is \(hashAlloc) ------------"))

            let traf: Int = (_troubleshooting?.traffic ?? 0)
            
            FlagshipLogManager.Log(level: .DEBUG, tag: .VISITOR, messageToDisplay: FSLogMessage.MESSAGE("The range allocation for TR bucket is \(traf) ------------"))
            
            return hashAlloc <= (_troubleshooting?.traffic ?? 0)
        } else {
            return false
        }
    }
    
    func isVisitorHasConsented()->Bool {
        return _hasConsented
    }
    
    func updateConsent(newValue: Bool) {
        _hasConsented = newValue
        evaluateTroubleShootingConditions()
    }
    
    // Developer data usage
    
    // Evaluate data usage to allow reporting
    func evaluateDataUsageTrackingAllocated()->Bool {
        return true
    }
    
    // Send Troubleshooting Report
    func sendTroubleshootingReport(_trHit: TroubleshootingHit) {
        if troubleShootingReportAllowed {
            // Create url string endpoint
            
            do {
                let dataToSend = try JSONSerialization.data(withJSONObject: _trHit.bodyTrack as Any, options: .prettyPrinted)
                
                print("##############@ Report Troubleshooting #######################")
                
                print(dataToSend.prettyPrintedJSONString)
                
                print("##############@ Report Troubleshooting #######################")

                if let urlReport = URL(string: FSTroubleshootingUrlString) {
                    _service?.sendRequest(urlReport, type: .Tracking, data: dataToSend) { _, error in
                        if error != nil {
                            FlagshipLogManager.Log(level: .ERROR, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Failed to send troubleshoting report : \(error.debugDescription)"))
                        } else {
                            FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Sucess to send troubleshoting report"))
                        }
                    }
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
