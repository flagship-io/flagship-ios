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

/// Delegate to check if the capture is completed
protocol FSEmotionAiDelegate {
    func emotionAiCaptureCompleted(_ score: String?)
}

class FSEmotionAI: NSObject, UIGestureRecognizerDelegate {
    var delegate: FSEmotionAiDelegate?
    var timeStartingCollect: TimeInterval = 0
    var tapGesture: UITapGestureRecognizer? // UILongPressGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    var longPressGesture: UILongPressGestureRecognizer?

    var pollingScore: FSPollingScore?

    var visitorId: String

    var service: FSService?

    var cursorPosition = ""
    var scrollPosition = ""

    // See later how to do better
    var window: UIWindow?

    private var touchStartTime: Date?

    // Init with visitor id
    init(visitorId: String) {
        self.visitorId = visitorId
        // Create service componont to send send event
        service = FSService(Flagship.sharedInstance.envId ?? "", "", self.visitorId)
    }

    func startEAICollectForView(_ window: UIWindow?) {
        self.window = window
        // Init the time
        timeStartingCollect = Date().timeIntervalSince1970

        // Add tap gesture recognizer
        //  tapGesture = UITapGestureRecognizer(target: self, action: nil)
        // tapGesture?.delegate = self
        // Add pan gesture recognizer
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture?.cancelsTouchesInView = false
        panGesture?.delegate = self

        if let aGesture = panGesture {
            longPressGesture?.require(toFail: aGesture)
        }

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture?.cancelsTouchesInView = false
        longPressGesture?.minimumPressDuration = 0

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
                    if let pan = self.panGesture, /* let tap = self.tapGesture, */ let longPress = self.longPressGesture {
                        self.window?.addGestureRecognizer(pan)
                        // self.window?.addGestureRecognizer(tap)
                        self.window?.addGestureRecognizer(longPress)
                    }
                }
            }
        }
    }

    private func sendEvent(_ event: FSTracking, isLastEvent: Bool) {
        sendEmotionEvent(event)
        if isLastEvent {
            print(" @@@@@@@@@@@@ Send Last Event and STOP COLLECTING @@@@@@@@@@@@@@@")
            stopCollecting()
            // Start get scoring from remote
            pollingScore = FSPollingScore(visitorId: visitorId, delegate: delegate)
        }
    }

    private func stopCollecting() {
        panGesture?.isEnabled = false
        longPressGesture?.isEnabled = false
    }

    /// Building events
    private func buildEvent(_ gesture: UIGestureRecognizer, duration: TimeInterval = 0) -> FSTracking {
        let location = gesture.location(in: gesture.view) // Revoir ça
        let point = CGPoint(x: location.x, y: location.y)

        let emotionAI = FSEmotionEvent("\(point.x)", "\(point.y)", pClickDuration: "\(duration)")

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

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            touchStartTime = Date() // Start timing
        case .ended:
            let deltaTime = Date().timeIntervalSince1970 - timeStartingCollect
            let deltaSecond = Int(deltaTime.rounded())

            print("@@@@@@@@@@@@ Handle Long Press after \(deltaSecond) @@@@@@@@@@@@@@@@@@@@")

            if let startTime = touchStartTime {
                let duration = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds
                print("Press duration: \(duration) ms")

                let deltaTime = Date().timeIntervalSince1970 - timeStartingCollect
                let deltaSecond = Int(deltaTime.rounded())

                if let topController = window?.visibleViewController() {
                    let eventClikc = FSEmotionEvent("\(gesture.location(in: window).x)", "\(gesture.location(in: window).y)", pClickDuration: "")
                    eventClikc.currentScreen = NSStringFromClass(topController.classForCoder)
                    if deltaSecond < FSAIDuration_30 {
                        sendEvent(eventClikc, isLastEvent: false)
                    } else if deltaSecond <= 120 {
                        sendEvent(eventClikc, isLastEvent: true)
                    } else {
                        // visitor not scored
                    }
                }
            }
            touchStartTime = nil
        default:
            break
        }
    }

    // Handle pan gesture
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)

        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumIntegerDigits = 0
        formatter.maximumFractionDigits = 5
        let number = NSNumber(value: NSDate().timeIntervalSince1970)
        let formattedValue = formatter.string(from: number)!
        let last5digitTimeStmap = formattedValue.replacingOccurrences(of: ",", with: "")

        switch gesture.state {
        case .began:
            cursorPosition = ""
            scrollPosition = ""
            cursorPosition.append("\(location.y),\(location.x),\(last5digitTimeStmap);")
            scrollPosition.append("\(location.x),\(location.y),\(last5digitTimeStmap);")

        case .changed:
            cursorPosition.append("\(location.y),\(location.x),\(last5digitTimeStmap);")
            scrollPosition.append("\(location.x),\(location.y),\(last5digitTimeStmap);")

        case .ended:
            print("-------- Move cursor gesture -----------")
            cursorPosition.append("\(location.y),\(location.x),\(last5digitTimeStmap);")
            scrollPosition.append("\(location.x),\(location.y),\(last5digitTimeStmap);")

            if let topController = window?.visibleViewController() {
                // Create the visitor event
                let visitorEvent = FSEmotionEvent("", "", pCursorPosition: cursorPosition, pScrollPosition: scrollPosition)
                // Set the name for screen event
                visitorEvent.currentScreen = NSStringFromClass(topController.classForCoder)

                let deltaTime = Date().timeIntervalSince1970 - timeStartingCollect
                let deltaSecond = Int(deltaTime.rounded())

                if deltaSecond < FSAIDuration_30 {
                    sendEvent(visitorEvent, isLastEvent: false)
                } else if deltaSecond <= 120 {
                    sendEvent(visitorEvent, isLastEvent: true)
                } else {
                    // Visitor Not Scored
                }
            }

        default:
            break
        }
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapGesture {
            print("The tap event happen")
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
