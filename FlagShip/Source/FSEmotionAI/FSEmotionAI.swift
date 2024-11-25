//
//  FSEmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 15/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import UIKit

class FSEmotionAI: NSObject, UIGestureRecognizerDelegate {
    var timeStartingCollect: TimeInterval = 0
    var tapGesture: UITapGestureRecognizer?

    var pollingScore: FSPollingScore?

    var visitorId: String

    var service: FSService?

    // Init with visitor id
    init(visitorId: String) {
        self.visitorId = visitorId
        // Create service componont to send send event
        service = FSService(Flagship.sharedInstance.envId ?? "", "", self.visitorId)
    }

    func startEAICollectForView(view: UIView) {
        // Init the time
        timeStartingCollect = Date().timeIntervalSince1970

        // Add a tap gesture recognizer to the view
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        DispatchQueue.main.async {
            view.addGestureRecognizer(self.tapGesture!)
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let deltaTime = Date().timeIntervalSince1970 - timeStartingCollect
        let deltaSecond = Int(deltaTime.rounded())

        print("The event happen after \(deltaSecond)")

        if deltaSecond < 30 {
            sendEvent(buildEvent(gesture), isLastEvent: false)
        } else if deltaSecond <= 120 {
            sendEvent(buildEvent(gesture), isLastEvent: true)
        } else {
            // visitor not scored
        }
    }
    
    

    private func sendEvent(_ event: FSTracking, isLastEvent: Bool) {
        if isLastEvent {
            print(" @@@@@@@@@@@@ Send Last Event and STOP COLLECTING @@@@@@@@@@@@@@@")
            stopCollecting()
            // Start get scoring from remote
            pollingScore = FSPollingScore(visitorId: visitorId)

        } else {
            print(" @@@@@@@@@@@@ Send Event @@@@@@@@@@@@@@@")
        }
    }

    private func stopCollecting() {
        tapGesture?.isEnabled = false
    }

    /// Building events
    private func buildEvent(_ gesture: UITapGestureRecognizer) -> FSTracking {
        return FSEmotionPageView("testcreen")
    }
}
