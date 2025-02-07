//
//  FSPollingScore.swift
//  Flagship
//
//  Created by Adel Ferguen on 20/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import UIKit

class FSPollingScore: NSObject {
    var timer: Timer?

    var pollingScore: FSRepeatingTimer?
    var retryCount: Int = 0
    var visitorId: String
    var anonymousId: String?

    var delegate: FSEmotionAiDelegate?

    init(visitorId: String, anonymousId: String? = nil, delegate: FSEmotionAiDelegate?) {
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.delegate = delegate
        super.init()
        self.pollingScore = FSRepeatingTimer(timeInterval: 0.5)
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.stopPollingScore), userInfo: nil, repeats: false)
        self.startPolling()
    }

    func startPolling() {
        FSDataUsageTracking.sharedInstance.processTSEmotionsCollect(criticalPoint: .EMOTIONS_AI_START_SCORING, visitorId: self.visitorId, anonymousId: self.anonymousId)
        self.pollingScore?.eventHandler = { [weak self] in
            if let self {
                self.retryCount += 1
                self.pollingScore?.suspend()
                FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("GET THE SCORE FROM THE SERVER - RETRY COUNT: \(self.retryCount)"))

                FSSettings().fetchScore(visitorId: self.visitorId, completion: { score, statusCode in

                    if statusCode == 204 {
                        // No Need to trigger when no scrore is ready
                        // self.delegate?.emotionAiCaptureCompleted(nil)
                        self.pollingScore?.resume()
                    } else if statusCode == 200 {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Score Successfully Received"))
                        self.delegate?.emotionAiCaptureCompleted(score)
                        self.timer?.invalidate() // Invalidate no need since we got the score 
                    } else {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("RESPONSE FROM THE SERVER - score not received - status code: \(statusCode)"))
                    }
                })
            }
        }

        self.pollingScore?.resume()
    }

    @objc func stopPollingScore() {
        // if reach this part ==> no score found
        FSDataUsageTracking.sharedInstance.processTSEmotionsCollect(criticalPoint: .EMOTIONS_AI_SCORING_FAILED, visitorId: self.visitorId, anonymousId: self.anonymousId)
        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Stop Polling Score-EmotionAI, Session Ended"))
        self.pollingScore?.suspend()
    }
}
