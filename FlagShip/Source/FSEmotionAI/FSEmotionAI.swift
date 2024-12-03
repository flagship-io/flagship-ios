//
//  FSEmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 15/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import UIKit

let FSEmotionAiUrl = "https://ariane.abtasty.com/emotionsai"

let FSAIDuration_30 = 30 + 5 // I added 5 seconds as marge
let FSAIDuration_120 = 120 // Duration for waiting the last event

class FSEmotionAI: NSObject, UIGestureRecognizerDelegate {
    var timeStartingCollect: TimeInterval = 0
    var tapGesture: UITapGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?

    var pollingScore: FSPollingScore?

    var visitorId: String

    var service: FSService?

    // Init with visitor id
    init(visitorId: String) {
        self.visitorId = visitorId
        // Create service componont to send send event
        service = FSService(Flagship.sharedInstance.envId ?? "", "", self.visitorId)
    }

    func startEAICollectForView(viewCtrl: UIViewController) {
        // Init the time
        timeStartingCollect = Date().timeIntervalSince1970

        // Add tap gesture recognizer
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        // Add pan gesture recognizer
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

        // Add a tap gesture recognizer to the view
        // tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

        // Create a pageview

        // Send the pageView at the start
        sendEmotionEvent(FSEmotionPageView("https://app.flagship.io/login")) { error in

            if error != nil {
                // Send page view with error
                print(error.debugDescription)
            } else {
                print("######## Start Collecting Emotional AI ##########")
                // Start collect AI
                DispatchQueue.main.async {
                    if let pan = self.panGesture, let tap = self.tapGesture {
                        viewCtrl.view.addGestureRecognizer(pan)
                        viewCtrl.view.addGestureRecognizer(tap)
                    }
                }
            }
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let deltaTime = Date().timeIntervalSince1970 - timeStartingCollect
        let deltaSecond = Int(deltaTime.rounded())

        print("The event happen after \(deltaSecond)")

        if deltaSecond < FSAIDuration_30 {
            sendEvent(buildEvent(gesture), isLastEvent: false)
        } else if deltaSecond <= 120 {
            sendEvent(buildEvent(gesture), isLastEvent: true)
        } else {
            // visitor not scored
        }
    }

    // Handle pan gesture
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        print("Cursor moved to: \(location)")

        // Optional: Check state for finer control
        switch gesture.state {
        case .began:
            print("Pan began at: \(location)")
        case .changed:
            print("Pan is moving to: \(location)")
        case .ended:
            print("Pan ended at: \(location)")
        default:
            break
        }
    }

    private func sendEvent(_ event: FSTracking, isLastEvent: Bool) {
        sendEmotionEvent(event)
        if isLastEvent {
            print(" @@@@@@@@@@@@ Send Last Event and STOP COLLECTING @@@@@@@@@@@@@@@")
            stopCollecting()
            // Start get scoring from remote
            pollingScore = FSPollingScore(visitorId: visitorId)
        }
    }

    private func stopCollecting() {
        tapGesture?.isEnabled = false
        panGesture?.isEnabled = false
    }

    /// Building events
    private func buildEvent(_ gesture: UITapGestureRecognizer) -> FSTracking {
        let location = gesture.location(in: gesture.view)
        let point = CGPoint(x: location.x, y: location.y)

        let emotionAI = FSEmotionEvent("\(point.x)", "\(point.y)", "", "")

        return emotionAI
    }

    private func sendEmotionEvent(_ aiHit: FSTracking, completion: ((Error?) -> Void)? = nil) {
        print(" @@@@@@@@@@@@ Send Emotion Page View @@@@@@@@@@@@@@@")
        // Set the visitor id
        aiHit.visitorId = visitorId
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: aiHit.bodyTrack as Any, options: .prettyPrinted)

            print("Sending the following payload : + \(dataToSend.prettyPrintedJSONString)")
            if let urlAI = URL(string: FSEmotionAiUrl) {
                service?.sendRequest(urlAI, type: .Tracking, data: dataToSend) { _, error in
                    if error != nil {
                        print("Failed to send EmotionAI : " + aiHit.type.typeString)
                    } else {
                        print("Success to send EmotionAI : " + aiHit.type.typeString)
                    }
                    completion?(error)
                }
            }

        } catch {
            print("Error on sending AI hit \(error.localizedDescription)")
        }
    }
}
