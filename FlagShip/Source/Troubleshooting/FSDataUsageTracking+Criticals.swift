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
    // Troubleshooting on error catched
    func processTSCatchedError(v: FSVisitor?, error: FlagshipError) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": v?.visitorId ?? "",
                                              "error.message": error.message]

        // Add context
        if let aV = v {
            criticalJson.merge(_createTRContext(aV)) { _, new in new }
        }

        // Send TS on error catched
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: CriticalPoints.ERROR_CATCHED.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Troubleshooting for Flag
    func proceesTSFlag(crticalPointLabel: CriticalPoints, f: FSFlag, v: FSVisitor?) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": v?.visitorId ?? "",
                                              "flag.key": f.key,
                                              "flag.defaultValue": "\(f.defaultValue ?? "nil")"]

        // Add context
        if let aV = v {
            criticalJson.merge(_createTRContext(aV)) { _, new in new }
        }

        // Send TS on Flag warninig
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: crticalPointLabel.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Troubleshooting on any request error
    func processTSHttpError(requestType: FSRequestType, _ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data? = nil) {
        var criticalLabel = ""
        switch requestType { case .Campaign:
            criticalLabel = CriticalPoints.GET_CAMPAIGNS_ROUTE_RESPONSE_ERROR.rawValue
        case .Activate:
            criticalLabel = CriticalPoints.SEND_ACTIVATE_HIT_ROUTE_ERROR.rawValue
        case .Tracking:
            criticalLabel = CriticalPoints.SEND_BATCH_HIT_ROUTE_RESPONSE_ERROR.rawValue
        case .KeyContext, .DataUsage: // Skip the process with thoses type of request
            return
        }

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
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: criticalLabel, pSpeceficCustomFields: criticalJson))
    }

    // Process http on bucketing error
    func processTSHttp(crticalPointLabel: CriticalPoints, _ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data? = nil) {
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
        // Send TS report
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: crticalPointLabel.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Process on download bucketing file
    func processTSBucketingFile(_ response: HTTPURLResponse?, _ request: URLRequest, _ data: Data) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": _visitorId]
        let httpFields: [String: String] = [
            "http.request.headers": request.allHTTPHeaderFields?.description ?? "",
            "http.request.method": request.httpMethod ?? "",
            "http.request.url": request.url?.absoluteString ?? "",
            "http.response.body": String(data.prettyPrintedJSONString ?? ""),
            "http.response.headers": response?.allHeaderFields.description ?? "",
            "http.response.code": String(describing: response?.statusCode ?? 0)
        ]
        criticalJson.merge(httpFields) { _, new in new }
        // Send TS report
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: _visitorId, pLabel: CriticalPoints.SDK_BUCKETING_FILE.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Troubleshooting on send hits
    func processTSHits(label: String, visitor: FSVisitor, hit: FSTrackingProtocol) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": visitor.visitorId,
                                              "visitor.anonymousId": visitor.anonymousId ?? "null"]

        // Add hits fields
        criticalJson.merge(createCriticalFieldsHits(hit: hit)) { _, new in new }

        // Send Troubleshooting
        sendTroubleshootingReport(_trHit:
            TroubleshootingHit(pVisitorId: visitor.visitorId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }

    // Troubleshooting on Fetching
    func processTSFetching(v: FSVisitor, campaigns: FSCampaigns?) {
        var criticalJson: [String: String] = ["visitor.sessionId": _visitorSessionId,
                                              "visitor.visitorId": v.visitorId,
                                              "visitor.anonymousId": v.anonymousId ?? "null"]

        // Add visitor fields
        criticalJson.merge(createCriticalFieldsForVisitor(v)) { _, new in new }

        // Add campaigns
        do {
            let restult = try JSONEncoder().encode(campaigns)
            if let outPutString = String(data: restult, encoding: .utf8) {
                criticalJson.merge(["visitor.campaigns": outPutString]) { _, new in new }
            }
        } catch {
            FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Error on decode campaigns"))
        }

        // Send TS Report
        sendTroubleshootingReport(_trHit: TroubleshootingHit(
            pVisitorId: v.visitorId, pLabel: CriticalPoints.VISITOR_FETCH_CAMPAIGNS.rawValue, pSpeceficCustomFields: criticalJson))
    }

    // Process on authenticate
    func processTSXPC(label: String, visitor: FSVisitor) {
        var criticalJson: [String: String] = [:]

        // Create ids
        let visitorIds = ["visitor.sessionId": _visitorSessionId,
                          "visitor.visitorId": visitor.visitorId,
                          "visitor.anonymousId": visitor.anonymousId ?? "null"]

        // Add ids visitor
        criticalJson.merge(visitorIds) { _, new in new }

        // Add visitor fields
        criticalJson.merge(_createTRContext(visitor)) { _, new in new }

        // Send TS report
        sendTroubleshootingReport(_trHit: TroubleshootingHit(
            pVisitorId: visitor.visitorId, pLabel: label, pSpeceficCustomFields: criticalJson))
    }

    //////////////////////////////////
    /// Create critical  fields //////
    /// //////////////////////////////

    // HITS
    func createCriticalFieldsHits(hit: FSTrackingProtocol) -> [String: String] {
        var hitFields: [String: String] = [:]

        for (hitKey, hitValue) in hit.bodyTrack {
            let itemFieldHit = ["hit.\(hitKey)": "\(hitValue)"]

            hitFields.merge(itemFieldHit) { _, new in new }
        }
        return hitFields
    }

    private func _createTRContext(_ pVisitor: FSVisitor) -> [String: String] {
        // Create flags fields
        var ctxFields: [String: String] = [:]
        for (ctxKey, ctxValue) in pVisitor.getContext() {
            let itemCtxFileds =
                ["visitor.context.\(ctxKey)": "\(ctxValue)"]
            ctxFields.merge(itemCtxFileds) { _, new in new }
        }

        return ctxFields
    }

    func createCriticalFieldsForVisitor(_ visitor: FSVisitor) -> [String: String] {
        var ret: [String: String] = [:]

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
                "sdk.config.timeout": String(aSdkConfig.timeout * 1000),
                "sdk.config.pollingTime": String(aSdkConfig.pollingTime * 1000),
                "sdk.config.usingCustomLogManager": "false",
                "sdk.config.usingCustomHitCache": String(!(aSdkConfig.cacheManager.hitCacheDelegate is FSDefaultCacheHit)),
                "sdk.config.usingCustomVisitorCache": String(!(aSdkConfig.cacheManager.cacheVisitorDelegate is FSDefaultCacheVisitor)),
                "sdk.config.usingOnVisitorExposed": String(aSdkConfig.onVisitorExposed != nil),
                "sdk.config.decisionApiUrl": FlagShipEndPoint,
                "sdk.config.trackingManager.strategy": aSdkConfig.trackingConfig.strategy.name,
                "sdk.config.trackingManager.batchIntervals": String(aSdkConfig.trackingConfig.batchIntervalTimer * 1000),
                "sdk.config.trackingManager.poolMaxSize": String(aSdkConfig.trackingConfig.poolMaxSize),
                "sdk.lastInitializationTimestamp": String(Flagship.sharedInstance.lastInitializationTimestamp),
                "sdk.config.logLevel": aSdkConfig.logLevel.name
            ]
        }
        return configFields
    }

    //////////////////////////
    // Data Usage Developer //
    //////////////////////////

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
