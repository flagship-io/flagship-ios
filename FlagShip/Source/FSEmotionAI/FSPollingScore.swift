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

    init(visitorId: String) {
        self.visitorId = visitorId
        super.init()
        self.pollingScore = FSRepeatingTimer(timeInterval: 0.5)
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.stopPollingScore), userInfo: nil, repeats: false)
        self.startPolling()
    }

    func startPolling() {
        self.pollingScore?.eventHandler = { [weak self] in
            if let self {
                self.retryCount += 1
                self.pollingScore?.suspend()
                print("GET MY SCORE FROM THE SERVER - RETRY COUNT: \(self.retryCount)")
                FSSettings.fetchScore(visitorId: self.visitorId, completion: { _, statusCode in

                    if statusCode == 204 {
                        print("RESPONSE FROM THE SERVER")
                        self.pollingScore?.resume()
                    } else if statusCode == 200 {
                        print("RESPONSE FROM THE SERVER - score successfully received")
                    } else {
                        print("RESPONSE FROM THE SERVER - score not received - status code: \(statusCode)")
                    }
                })
            }
        }

        self.pollingScore?.resume()
    }

    @objc func stopPollingScore() {
        print("Stop Polling Score and suspend the timer - End of Session EmotionAI")
        self.pollingScore?.suspend()
    }
}
