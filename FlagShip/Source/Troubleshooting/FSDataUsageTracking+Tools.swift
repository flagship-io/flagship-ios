//
//  FSTroubleshooting+Tools.swift
//  Flagship
//
//  Created by Adel Ferguen on 28/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

extension FSDataUsageTracking {
    // Evaluate conditions to allow TS (trouble shooting) reporting
    func evaluateTroubleShootingConditions() {
        // To allow the dataUsageTracking we have to check
        troubleShootingReportAllowed = isTimeSlotValide() && // TimeSlot

            isBucketTroubleshootingAllocated() && // Bucket Allocation for TR

            isVisitorHasConsented() // Visitor Consent

        if troubleShootingReportAllowed {
            FlagshipLogManager.Log(level: FSLevel.INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("-------------- Troubleshooting Allowed ✅✅✅✅✅ ---------------"))
        } else {
            // FlagshipLogManager.Log(level: FSLevel.INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("-------------- Troubleshooting NOT //Allowed ❌❌❌❌❌ --------------"))
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
            
            return hashAlloc <= (_troubleshooting?.traffic ?? 0)
        } else {
            return false
        }
    }
    
    // Evaluate data usage to allow reporting
    func evaluateDataUsageTrackingAllocated() {
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyyMMdd"
        let combinedId: String = _visitorId + formatDate.string(from: Date())
        
        let hashAlloc = Int(MurmurHash3.hash32(key: combinedId) % 100)
        
        // print(" -------- The hashalloc for \(combinedId) is \(hashAlloc) ----------")
        
        // Get the developer usage tracking
        let ret = _sdkConfig?.disableDeveloperUsageTracking ?? false
        
        dataUsageTrackingReportAllowed = hashAlloc <= FSDataUsageAllocationThreshold && !ret
        
        if dataUsageTrackingReportAllowed {
            FlagshipLogManager.Log(level: .INFO, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("-------------- Developer Usage Allowed ✅✅✅✅✅ ---------------"))
          
        } else {
            // print("-------------- Developer Usage not Allowed ❌❌❌❌❌ ---------------")
        }
    }
    
    /// TO DO Refarctor sends functions
    func sendDataReport(_ reportHit: FSTrackingProtocol) {
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: reportHit.bodyTrack as Any, options: .prettyPrinted)
            
            var urlString = FSTroubleshootingUrlString
            
            if reportHit.type == .USAGE {
                urlString = FSDeveloperUsageUrlString
            }

            if let urlReport = URL(string: urlString) {
                _service?.sendRequest(urlReport, type: .Tracking, data: dataToSend) { _, error in
                    if error != nil {
                        FlagshipLogManager.Log(level: .ERROR, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Failed to send troubleshoting report : \(error.debugDescription)"))
                    } else {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Success to send troubleshoting report"))
                    }
                }
            }
            
        } catch {
            FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .EXCEPTION, messageToDisplay: FSLogMessage.MESSAGE("Error on sending usage report \(error.localizedDescription)"))
        }
    }
}
