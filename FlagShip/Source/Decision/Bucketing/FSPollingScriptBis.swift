//
//  FSPollingScript.swift
//  FSPolling
//
//  Created by Adel on 27/10/2021.
//

import Foundation

/// This class responsible for fetching the script
class FSPollingScriptBis {
    var pollingIntervalTime: TimeInterval
    
    var pollingTimer: FSRepeatingTimer?
    
    var service: FSService
    
    init(pollingTime: TimeInterval) {
        pollingIntervalTime = pollingTime
        service = FSService(Flagship.sharedInstance.envId ?? "", Flagship.sharedInstance.apiKey ?? "", "")
        pollingTimer = FSRepeatingTimer(timeInterval: pollingTime)
        launchPolling()
    }
    
    public func launchPolling() {
        pollingTimer?.eventHandler = {
            self.pollingTimer?.suspend()
            self.service.getFSScript { bucketingScript, error in
                
                // Error occured when trying to get script
                if error != nil {
                    // Read from cache the bucket script
                    guard let storedBucket: FSBucket = FSStorageManager.readBucketFromCache() else {
                        // Exit the start with not ready status
                        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.NOCACHE_SCRIPT)
                        return
                    }
                    // Transmit stored script via notification
                    NotificationCenter.default.post(name: NSNotification.Name("onGetScriptNotification"), object: storedBucket, userInfo: nil)
                    Flagship.sharedInstance.updateStatusBis(storedBucket.panic ? .SDK_PANIC : .SDK_INITIALIZED)

                } else {
                    // Transmit new script via notification
                    NotificationCenter.default.post(name: NSNotification.Name("onGetScriptNotification"), object: bucketingScript, userInfo: nil)
                    if let aBucketingScript = bucketingScript {
                        Flagship.sharedInstance.updateStatusBis(aBucketingScript.panic ? .SDK_PANIC : .SDK_INITIALIZED)
                    }
                }
                if self.pollingIntervalTime > 0.0 { /// only once when timer is 0
                    self.pollingTimer?.resume()
                }
            }
        }
        pollingTimer?.resume()
    }
    
    public func cancelPolling() {
        pollingTimer?.suspend()
    }
}
