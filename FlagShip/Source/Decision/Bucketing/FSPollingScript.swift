//
//  FSPollingScript.swift
//  FSPolling
//
//  Created by Adel on 27/10/2021.
//

import Foundation


protocol FSPollingScriptDelegate{
    
    func onGetScript(_ newBucketing:FSBucket?, _ error:FSError?)
}


class FSPollingScript{
    
    /// This class responsible for fetching the script
    
    var pollingIntervalTime:TimeInterval
    
    var pollingTimer:FSRepeatingTimer?
    
    var delegate:FSPollingScriptDelegate?
    
    var service:FSService
    
    init(service:FSService, pollingTime:TimeInterval, delegate:FSBucketingManager){
        
        pollingIntervalTime = pollingTime
        self.service = service
        self.delegate = delegate
        pollingTimer = FSRepeatingTimer(timeInterval: pollingTime)
    }
    
    
    public func launchPolling(){
        
        pollingTimer?.eventHandler = {
            self.pollingTimer?.suspend()
            self.service.getFSScript { (bucketingScript, error) in
                
                /// Error occured when trying to get script
                if error != nil {

                    /// Read from cache the bucket script
                    guard let storedBucket: FSBucket =  FSStorageManager.readBucketFromCache() else {

                        // Exit the start with not ready status
                        FlagshipLogManager.Log(level:.ALL, tag:.BUCKETING, messageToDisplay:FSLogMessage.NOCACHE_SCRIPT)
                        self.delegate?.onGetScript(nil, error)

                        return
                    }
                    /// Transmit data to delegate
                    self.delegate?.onGetScript(storedBucket, nil)
                    
                } else {
                    
                    self.delegate?.onGetScript(bucketingScript, nil)
                }
                if (self.pollingIntervalTime > 0.0){ /// only once when timer is 0
                   
                    self.pollingTimer?.resume()
                }
            }
        }
        self.pollingTimer?.resume()
    }
    
    
    
    public func cancelPolling(){
        
        pollingTimer?.suspend()
    }
}

/// Inspsired from : https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9
class FSRepeatingTimer {

    let timeInterval: TimeInterval
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: self.timeInterval)
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()

    var eventHandler: (() -> Void)?

    private enum State {
        case suspended
        case resumed
    }

    private var state: State = .suspended

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }

    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }

}
