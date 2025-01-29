//
//  FSEmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 15/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import UIKit

let FSEmotionAiUrl = "https://ariane.abtasty.com/emotionsai"

let FSAIDuration_30 = 30.0 + 5 // I added x seconds as marge
let FSAIDuration_120 = 120.0 // Duration for waiting the last event

/// Delegate to check if the capture is completed
protocol FSEmotionAiDelegate {
    func emotionAiCaptureCompleted(_ score: String?)
}

enum FSEmotionCollectStatus: Int {
    case PROGRESS = 0
    case STOPED = 1
}

class FSEmotionAI: NSObject, UIGestureRecognizerDelegate {
    var currentScreenName: String?
    var delegate: FSEmotionAiDelegate?
    var timeStartCollecting: TimeInterval = 0
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

    var status: FSEmotionCollectStatus = .STOPED
    var swizzlingEnabled: Bool = false {
        didSet {
            if swizzlingEnabled {
                UIViewController.swizzleViewDidAppear
            }
        }
    }

    // Init with visitor id
    init(visitorId: String, usingSwizzling: Bool = false) {
        self.visitorId = visitorId
        // Create service componont to send send event
        service = FSService(Flagship.sharedInstance.envId ?? "", "", self.visitorId)

        swizzlingEnabled = usingSwizzling

        if usingSwizzling {
            UIViewController.swizzleViewDidAppear
        }
    }

    func startEAICollectForView(_ window: UIWindow?, nameScreen: String? = nil, completion: ((Bool) -> Void)? = nil) {
        if status == .PROGRESS {
            FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("The Emotions AI collection is already in progress"))

            return
        }
        status = .PROGRESS
        self.window = window
        // Set current screen name
        currentScreenName = nameScreen
        // Init the time
        timeStartCollecting = Date().timeIntervalSince1970

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture?.cancelsTouchesInView = false
        panGesture?.delegate = self

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture?.cancelsTouchesInView = false
        longPressGesture?.minimumPressDuration = 0
        longPressGesture?.delegate = self

        // Create a pageview
        // Send the pageView at the start WITH THE NAME PROVIDED OR FORMAT THE DEFAULT ONE

        let pNameScreen: String = currentScreenName ?? window?.getNameForVisibleViewController() ?? ""

        sendEmotionEvent(FSEmotionPageView(pNameScreen)) { error in

            if error != nil {
                completion?(false)
                // Send page view with error
                //  print(error.debugDescription)
            } else {
                completion?(true)
                FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Start Collecting EmotionAI"))
                // Start collect AI
                DispatchQueue.main.async {
                    if let pan = self.panGesture, let longPress = self.longPressGesture {
                        self.window?.addGestureRecognizer(pan)
                        // self.window?.addGestureRecognizer(tap)
                        self.window?.addGestureRecognizer(longPress)
                        // Manage the gestures
                        longPress.require(toFail: pan)

                        // Add an observer for a specific notification
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(self.handleNotification(_:)),
                                                               name: NSNotification.Name("FSViewDidAppear"),
                                                               object: nil)
                    }
                }
            }
        }
    }

    func sendEvent(_ event: FSTracking, isLastEvent: Bool) {
        sendEmotionEvent(event)
        if isLastEvent {
            FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Send last EAI event and STOP COLLECTING"))
            stopCollecting()
            // Start get scoring from remote
            pollingScore = FSPollingScore(visitorId: visitorId, delegate: delegate)
        }
    }

    private func stopCollecting() {
        panGesture?.isEnabled = false
        longPressGesture?.isEnabled = false
        status = .STOPED
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FSViewDidAppear"), object: nil)
        if swizzlingEnabled {
            UIViewController.revertSwizzleViewDidAppear()
        }
    }

    /// Building events
    private func buildEvent(_ gesture: UIGestureRecognizer, duration: TimeInterval = 0) -> FSTracking {
        let location = gesture.location(in: gesture.view) // Revoir ça
        let point = CGPoint(x: location.x, y: location.y)

        let emotionAI = FSEmotionEvent("\(point.x)", "\(point.y)", pClickDuration: "\(duration)")

        return emotionAI
    }

    private func sendEmotionEvent(_ aiHit: FSTracking, completion: ((Error?) -> Void)? = nil) {
        FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Send EmotionAI : " + aiHit.type.typeString))

        // Set the visitor id
        aiHit.visitorId = visitorId
        do {
            let dataToSend = try JSONSerialization.data(withJSONObject: aiHit.bodyTrack as Any, options: .prettyPrinted)

            //print("Sending the following payload : + \(dataToSend.prettyPrintedJSONString)")
            if let urlAI = URL(string: FSEmotionAiUrl) {
                service?.sendRequest(urlAI, type: .Tracking, data: dataToSend) { _, error in
                    if error != nil {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Failed to send EmotionAI : " + aiHit.type.typeString))
                    } else {
                        FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Success to send EmotionAI : " + aiHit.type.typeString))
                    }
                    completion?(error)
                }
            }

        } catch {
            FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("Error on sending AI hit \(error.localizedDescription)"))
        }
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            touchStartTime = Date() // Start timing
        case .ended:
            if let startTime = touchStartTime {
                let duration = Date().timeIntervalSince(startTime) * 1000 // Convert to milliseconds

                // Delta from start collecting
                let deltaTime = Date().timeIntervalSince1970 - timeStartCollecting
                
                FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("handle tap at \(deltaTime) from start collecting emotionAI"))


                // Create event
                let eventClikc = FSEmotionEvent("\(gesture.location(in: window).x)", "\(gesture.location(in: window).y)", pClickDuration: "\(duration)")

                eventClikc.currentScreen = currentScreenName ?? window?.getNameForVisibleViewController() ?? ""
                if deltaTime < FSAIDuration_30 {
                    sendEvent(eventClikc, isLastEvent: false)
                } else if deltaTime <= FSAIDuration_120 {
                    sendEvent(eventClikc, isLastEvent: true)
                } else {
                    // visitor not scored
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
            cursorPosition.append("\(location.y),\(location.x),\(last5digitTimeStmap);")
            scrollPosition.append("\(location.x),\(location.y),\(last5digitTimeStmap);")

            let visitorEvent = FSEmotionEvent("", "", pCursorPosition: cursorPosition, pScrollPosition: scrollPosition)
            // Set the name for screen event
            visitorEvent.currentScreen = currentScreenName ?? window?.getNameForVisibleViewController() ?? ""

            let deltaTime = Date().timeIntervalSince1970 - timeStartCollecting

            FlagshipLogManager.Log(level: .DEBUG, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("handle Pan at \(deltaTime) from start collecting emotionAI"))

            if deltaTime < FSAIDuration_30 {
                sendEvent(visitorEvent, isLastEvent: false)
            } else if deltaTime <= FSAIDuration_120 {
                sendEvent(visitorEvent, isLastEvent: true)
            } else {
                // Visitor Not Scored
            }

        default:
            break
        }
    }

    // Handle the notification
    @objc func handleNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            // print("Received notification with userInfo: \(userInfo)")
            if let screenName = userInfo["dl"] as? String {
                // Update current name for screen name
                currentScreenName = screenName
                let pageView = FSEmotionPageView(screenName)
                sendEmotionEvent(pageView)
            }

        } else {
            // user info nil
            FlagshipLogManager.Log(level: .ERROR, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("userInfo is nil on handleNotification"))
        }
    }

    // Notify the application when the screen changes
    func onAppScreenChange(_ screenName: String) {
        NotificationCenter.default.post(name: NSNotification.Name("FSViewDidAppear"),
                                        object: nil,
                                        userInfo: ["dl": screenName])
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // tap / click  gesture
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

extension UIViewController {
    static let swizzleViewDidAppear: Void = {
        let originalSelector = #selector(viewDidAppear(_:))
        let swizzledSelector = #selector(swizzled_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    static func revertSwizzleViewDidAppear() {
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzled_viewDidAppear(_:))

        guard let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector) else { return }

        method_exchangeImplementations(swizzledMethod, originalMethod)
    }

    @objc func swizzled_viewDidAppear(_ animated: Bool) {
        // Call the original method
        swizzled_viewDidAppear(animated)

        NotificationCenter.default.post(name: NSNotification.Name("FSViewDidAppear"),
                                        object: nil,
                                        userInfo: ["dl": NSStringFromClass(classForCoder)])
    }
}
