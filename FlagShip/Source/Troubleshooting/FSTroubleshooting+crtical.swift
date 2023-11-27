//
//  FSTroubleshooting+crtical.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

let DataUsageLabel = "SDK_CONFIG"

extension FSDataUsageTracking {
    // TS Error catched
    func processTSCatchedError(v: FSVisitor?, error: FlagshipError) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId,
                                              "error.message": error.message]

        // Add context
        if let aV = v {
            criticalJson.merge(_createTRContext(aV)) { _, new in new }
        }

        // Send TS on Flag warinig
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: CriticalPoints.ERROR_CATCHED.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // TS Flag
    func proceesTSFlag(crticalPointLabel: CriticalPoints, f: FSFlag, v: FSVisitor?) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId,
                                              "flag.key": f.key,
                                              "flag.defaultValue": "\(f.defaultValue ?? "nil")"]

        // Add context
        if let aV = v {
            criticalJson.merge(_createTRContext(aV)) { _, new in new }
        }

        // Send TS on Flag warinig
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: crticalPointLabel.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // FSRequestType
    func processTSHttpError(requestType: FSRequestType, _ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data? = nil) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.body": String(data?.prettyPrintedJSONString ?? ""),
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": "\(response?.statusCode)"
        ]
        criticalJson.merge(httpFields) { _, new in new }

        var criticalLabel = ""
        switch requestType { case .Campaign:
            criticalLabel = CriticalPoints.GET_CAMPAIGNS_ROUTE_RESPONSE_ERROR.rawValue
        case .Activate:
            criticalLabel = CriticalPoints.SEND_ACTIVATE_HIT_ROUTE_ERROR.rawValue
        case .Tracking:
            criticalLabel = CriticalPoints.SEND_BATCH_HIT_ROUTE_RESPONSE_ERROR.rawValue
        case .KeyContext:
            return
        }

        // Send TS report on http error
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: criticalLabel, pSpeceficCustomFields: criticalJson))
    }

    func processTSHttp(crticalPointLabel: CriticalPoints, _ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data? = nil) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.body": String(data?.prettyPrintedJSONString ?? ""),
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": "\(response?.statusCode)"
        ]
        criticalJson.merge(httpFields) { _, new in new }
        // Send TS report
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: crticalPointLabel.rawValue, pSpeceficCustomFields: criticalJson))
    }

    func processTSBucketingFile(_ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.body": String(data.prettyPrintedJSONString ?? ""),
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": "\(response?.statusCode)"
        ]
        criticalJson.merge(httpFields) { _, new in new }
        // Send TS report
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: CriticalPoints.SDK_BUCKETING_FILE.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // TS Send Hit
    func processTSHits(label: String, visitor: FSVisitor, hit: FSTrackingProtocol) {
        var criticalJson: [String: String] = [:]
        // Create trio ids
        let visitorIds = ["visitor.sessionId": _visitorSessionId,
                          "visitor.visitorId": visitor.visitorId,
                          "visitor.anonymousId": visitor.anonymousId ?? "null"]
        // Add Trio ids
        criticalJson.merge(visitorIds) { _, new in new }

        // Add hits fields
        criticalJson.merge(createCriticalFieldsHits(hit: hit)) { _, new in new }

        // Send TS report
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: visitor.visitorId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }

    // TS on Fetching
    func processTSFetching(pVisitor: FSVisitor) {
        var criticalJson: [String: String] = [:]

        // Add visitor fields
        criticalJson.merge(createCriticalFieldsForVisitor(pVisitor)) { _, new in new }

        // Send TS report
        sendTroubleshootingReport(_trHit: TroubleshootingHit(
            pVisitorId: pVisitor.visitorId, pLabel: CriticalPoints.VISITOR_FETCH_CAMPAIGNS.rawValue, pSpeceficCustomFields: criticalJson))
    }

    func processTSXPC(label: String, pVisitor: FSVisitor) {
        var criticalJson: [String: String] = [:]

        // Create trio ids
        let visitorIds = ["visitor.sessionId": _visitorSessionId,
                          "visitor.visitorId": pVisitor.visitorId,
                          "visitor.anonymousId": pVisitor.anonymousId ?? "null"]

        // Add ids visitor
        criticalJson.merge(visitorIds) { _, new in new }

        // Add visitor fields
        criticalJson.merge(createCrticalXpc(pVisitor)) { _, new in new }

        // Send TS report
        sendTroubleshootingReport(_trHit: TroubleshootingHit(
            pVisitorId: pVisitor.visitorId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }

    //////////////////////////////////
    /// Create critical  fields //////
    /// //////////////////////////////

    // HITS
    private func createCriticalFieldsHits(hit: FSTrackingProtocol) -> [String: String] {
        var hitFields: [String: String] = [:]

        for (hitKey, hitValue) in hit.bodyTrack {
            let itemFieldHit = ["hit.\(hitKey)": "\(hitValue)"]

            hitFields.merge(itemFieldHit) { _, new in new }
        }
        return hitFields
    }

    // VISITOR-AUTHENTICATE
    private func createCrticalXpc(_ pVisitor: FSVisitor) -> [String: String] {
        var ret: [String: String] = [:]

        ret = _createTRContext(pVisitor)

        return ret
    }

    private func _createTRContext(_ pVisitor: FSVisitor) -> [String: String] {
        // Create flags fields
        var ctxFields: [String: String] = [:]

        for (ctxKey, ctxValue) in pVisitor.getContext() {
            let itemCtxFileds = [
                "visitor.context.\(ctxKey)": "\(ctxValue)"
            ]

            ctxFields.merge(itemCtxFileds) { _, new in new }
        }

        return ctxFields
    }

    private func createCriticalFieldsForVisitor(_ visitor: FSVisitor) -> [String: String] {
        var ret: [String: String] = [:]

        // Create trio ids
        let visitorIds = ["visitor.sessionId": _visitorSessionId,
                          "visitor.visitorId": visitor.visitorId,
                          "visitor.anonymousId": visitor.anonymousId ?? "null"]

        // Add ids visitor
        ret.merge(visitorIds) { _, new in new }

        // Create flags fields
        var flagFields: [String: String] = [:]

        for (flagKey, flagModification) in visitor.currentFlags {
            let itemFlagFileds: [String: String] = ["visitor.flags.\(flagKey).key": flagKey,
                                                    "visitor.flags.\(flagKey).value": "\(flagModification.value)",
                                                    "visitor.flags.\(flagKey).metadata.campaignId": flagModification.campaignId,
                                                    "visitor.flags.\(flagKey).metadata.variationGroupId":
                                                        flagModification.variationGroupId,
                                                    "visitor.flags.\(flagKey).metadata.variationId":
                                                        flagModification.variationId,
                                                    "visitor.flags.\(flagKey).metadata.isReference":
                                                        String(flagModification.isReference),
                                                    "visitor.flags.\(flagKey).metadata.campaignType":
                                                        String(flagModification.type),
                                                    "visitor.flags.\(flagKey).metadata.slug": flagModification.slug]

            flagFields.merge(itemFlagFileds) { _, new in new }
        }
        // Add flags
        ret.merge(flagFields) { _, new in new }

        // Create campaigns // TODO

        // Create assignement
        var assignmentsFields: [String: String] = [:]

        for (key, value) in visitor.assignedVariationHistory {
            assignmentsFields.updateValue(value, forKey: "visitor.assignments.\(key)")
        }
        if !assignmentsFields.isEmpty {
            // Add assignement
            ret.merge(assignmentsFields) { _, new in new }
        }

        // Add configs fields
        ret.merge(createConfigFields()) { _, new in new }

        // Add Context fields
        ret.merge(_createTRContext(visitor)) { _, new in new }

        return ret
    }

    func createConfigFields() -> [String: String] {
        var configFields: [String: String] = [:]
        if let aSdkConfig = _sdkConfig {
            configFields = [
                "sdk.status": Flagship.sharedInstance.currentStatus.name,
                "sdk.config.mode": (aSdkConfig.mode == .DECISION_API) ? "DECISION_API" : "BUCKETING",
                "sdk.config.timeout": String(aSdkConfig.timeout),
                "sdk.config.pollingTime": String(aSdkConfig.pollingTime),
                "sdk.config.usingCustomLogManager": "false",
                "sdk.config.usingCustomHitCache": String(aSdkConfig.cacheManager.hitCacheDelegate is FSDefaultCacheHit),
                "sdk.config.usingCustomVisitorCache": String(aSdkConfig.cacheManager.cacheVisitorDelegate is FSDefaultCacheVisitor),
                "sdk.config.usingOnVisitorExposed": String(aSdkConfig.onVisitorExposed != nil),
                "sdk.config.decisionApiUrl": FlagShipEndPoint,
                "sdk.config.trackingManager.strategy": aSdkConfig.trackingConfig.strategy.name,
                "sdk.config.trackingManager.batchIntervals": String(aSdkConfig.trackingConfig.batchIntervalTimer),
                "sdk.config.trackingManager.poolMaxSize": String(aSdkConfig.trackingConfig.poolMaxSize),
                "sdk.lastInitializationTimestamp": String(Flagship.sharedInstance.lastInitializationTimestamp)
            ]
        }
        return configFields
    }

    // Data Usage Developer

    // Create data usage information
    func processDataUsageTracking(v: FSVisitor) {
        var dataUsageJson: [String: String] = [:]

        // Add config infos
        dataUsageJson.merge(createConfigFields()) { _, new in new }

        // Send Data usage report
        sendDataUsageReport(_duHit: FSDataUsageHit(
            pVisitorId: _visitorSessionId, pLabel: DataUsageLabel, pSpeceficCustomFields: dataUsageJson))
    }
}
