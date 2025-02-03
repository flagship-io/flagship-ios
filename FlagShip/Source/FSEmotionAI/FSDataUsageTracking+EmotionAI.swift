//
//  FSDataUsageTracking+EmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 03/02/2025.
//  Copyright © 2025 FlagShip. All rights reserved.
//

import Foundation

extension FSDataUsageTracking {
    func processTSEmotionHits(visitorId: String, anonymousId: String?, hit: FSTrackingProtocol) {
        let label = (hit.type == .EMOTION_AI) ? CriticalPoints.EMOTION_AI_PAGE_VIEW.rawValue : CriticalPoints.EMOTION_AI_PAGE_VIEW.rawValue

        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": visitorId,
                                              "visitor.anonymousId": anonymousId ?? "null"]

        // Add hits fields
        criticalJson.merge(createCriticalFieldsHits(hit: hit)) { _, new in new }

        // Send Troubleshooting
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: visitorId, pAnonymousId: anonymousId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }
}
