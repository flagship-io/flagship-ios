//
//  FSDataUsageTracking+EmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 03/02/2025.
//  Copyright © 2025 FlagShip. All rights reserved.
//

import Foundation

extension FSDataUsageTracking {
    func processTSEmotionsHits(visitorId: String, anonymousId: String?, hit: FSTrackingProtocol) {
        let label = (hit.type == .EMOTION_AI) ? CriticalPoints.EMOTIONS_AI_PAGE_VIEW.rawValue : CriticalPoints.EMOTIONS_AI_PAGE_VIEW.rawValue

        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": visitorId,
                                              "visitor.anonymousId": anonymousId ?? "null"]

        // Add hits fields
        criticalJson.merge(createCriticalFieldsHits(hit: hit)) { _, new in new }

        // Send Troubleshooting
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: visitorId, pAnonymousId: anonymousId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }

    // Troubleshooting on any request error
    func processTSEmotionsSettingsError(label: CriticalPoints, _ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data? = nil) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.body": String(data?.prettyPrintedJSONString ?? ""),
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": String(describing: response?.statusCode ?? 0)
        ]
        criticalJson.merge(httpFields) { _, new in new }

        // Send Troubleshooting report on http error
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pAnonymousId: nil, pLabel: label.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Get score with success
    func processTSEmotionsScoreSuccess(visitorId: String, anonymousId: String?, response: HTTPURLResponse?, _ request: URLRequest, _ score: String?) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId,
                                              "visitor.eai.eas": score ?? ""]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": String(describing: response?.statusCode ?? 0)
        ]
        criticalJson.merge(httpFields) { _, new in new }

        // Send Troubleshooting report on http error
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pAnonymousId: nil, pLabel: CriticalPoints.EMOTIONS_AI_SCORE.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Cached Score
    func processTSEmotionsCachedScore(visitorId: String, anonymousId: String?, score: String?) {
        let criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId,
                                              "visitor.anonymousId": anonymousId ?? "",
                                              "visitor.eai.eas": score ?? ""]

        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pAnonymousId: nil, pLabel: CriticalPoints.EMOTIONS_AI_SCORE_FROM_LOCAL_CACHE.rawValue, pSpeceficCustomFields: criticalJson))
    }

    func processTSEmotionsCollect(criticalPoint: CriticalPoints, visitorId: String, anonymousId: String?, score: String? = nil) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": visitorId,
                                              "visitor.anonymousId": anonymousId ?? "",
                                              "visitor.eai.timestamp": FSTools.getUtcTimestamp()]

        if let aScore = score {
            criticalJson.merge(["visitor.eai.eas": aScore]) { _, new in new }
        }

        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pAnonymousId: anonymousId, pLabel: criticalPoint.rawValue, pSpeceficCustomFields: criticalJson))
    }
}
