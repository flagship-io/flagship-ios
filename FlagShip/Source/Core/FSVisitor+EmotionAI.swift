//
//  FSVisitor+EmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 22/09/2025.
//  Copyright © 2025 FlagShip. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

extension FSVisitor: FSEmotionAiDelegate {
    public func collectEmotionsAIEvents(window: UIWindow?, screenName: String? = nil, usingSwizzling: Bool = false) {
        if Flagship.sharedInstance.eaiCollectEnabled == true {
            self.strategy?.getStrategy().collectEmotionsAIEvents(window: window, screenName: screenName, usingSwizzling: usingSwizzling)
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .EMOTIONS_AI, messageToDisplay: FSLogMessage.MESSAGE("The Emotion AI feature is not activated"))
        }
    }

    public func onAppScreenChange(_ screenName: String) {
        self.strategy?.getStrategy().onAppScreenChange(screenName)
    }

    /// Delegate method called when the score is available
    func emotionAiCaptureCompleted(_ score: String?) {
        //  print(" @@@@@@@@@@@@@ The delegate with score \(score ?? "nil") has been called @@@@@@@@@@@@@")
        self.eaiVisitorScored = (score == nil) ? false : true

        if Flagship.sharedInstance.eaiActivationEnabled {
            self.emotionScoreAI = score
            // Update the context
            if let aScore = score {
                self.context.updateContext("eai::eas", aScore)
            }
        } else {
            print(" @@@@@@@@@@@@@ eaiActivationEnabled is false will not communicate the score value @@@@@@@@@@@@@")
        }

        self.strategy?.getStrategy().cacheVisitor()
        // TR for emotion AI
        FSDataUsageTracking.sharedInstance.processTSEmotionsCollect(criticalPoint: .EMOTIONS_AI_SCORING_SUCCESS, visitorId: self.visitorId, anonymousId: self.anonymousId, score: score)
    }
}
#endif
