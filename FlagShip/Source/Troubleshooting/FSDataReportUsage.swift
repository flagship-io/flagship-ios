//
//  FSDataReportUsage.swift
//  Flagship
//
//  Created by Adel Ferguen on 15/11/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

let troubleShootingVersion = "1"
let stackType = "SDK"
let stackName = "iOS"

// This enum describe the level gievn to hits Troubleshooting or DeveloperUsage
enum HitUsageLevel: String {
    case INFO
    case ERROR
    case WARNING
}

class TroubleshootingHit: FSTracking {
    // Commun Fields
    var _communCustomFields: [String: String] = [:]

    // this is the out put will add into it the custom variable
    // Custom Variable
    var speceficCustomFields: [String: String] = [:]

    // Label for the critical point
    var label: String = ""

    // Level by default is INFO
    var hitLevelUsage: HitUsageLevel = .INFO

    init(pVisitorId: String, pAnonymousId: String?, pLabel: String, pSpeceficCustomFields: [String: String]) {
        super.init()
        // Set the vid
        visitorId = pVisitorId
        // Set the annonymous id
        anonymousId = pAnonymousId

        // Set the Type
        type = .TROUBLESHOOTING

        // Set The Label
        label = pLabel

        // Set Level according to the type
        if label.contains("ERROR") {
            hitLevelUsage = .ERROR
        } else if label.contains("WARNING") || label.contains("FLAG_NOT_FOUND") {
            hitLevelUsage = .WARNING
        } else {
            hitLevelUsage = .INFO
        }

        // Fill with a specefic values
        speceficCustomFields.merge(pSpeceficCustomFields) { _, new in new }

        // Fill the commun CV dico
        fillTheCommunFieldsAndCompleteWithCustom()
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override var bodyTrack: [String: Any] {
        var customBody: [String: Any] = super.bodyTrack

        // Set Type event "Troubleshooting"
        customBody.updateValue(type.typeString, forKey: "t")
        // Add Commun
        customBody.merge(communBodyTrack) { _, new in new }
        // Update with commun custom fields
        customBody.updateValue(_communCustomFields, forKey: "cv")

        return customBody
    }

    func fillTheCommunFieldsAndCompleteWithCustom() {
        _communCustomFields = [
            "version": troubleShootingVersion,
            "envId": Flagship.sharedInstance.envId ?? "",
            "timestamp": FSTools.getUtcTimestamp(),
            "timeZone": TimeZone.current.abbreviation() ?? "",
            "label": label,
            "stack.type": stackType,
            "stack.name": stackName,
            "stack.version": FlagShipVersion,
            "flagshipInstanceId":
                FSTools.generateUuidv4(),
            "logLevel": hitLevelUsage.rawValue
        ]
        _communCustomFields.merge(speceficCustomFields) { _, new in new }
    }
}

class FSDataUsageHit: TroubleshootingHit {
    override init(pVisitorId: String, pAnonymousId: String?, pLabel: String, pSpeceficCustomFields: [String: String]) {
        super.init(pVisitorId: pVisitorId, pAnonymousId: pAnonymousId, pLabel: pLabel, pSpeceficCustomFields: pSpeceficCustomFields)
        type = .USAGE
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

enum CriticalPoints: String {
    // Trigger on fetch flags.
    case VISITOR_FETCH_CAMPAIGNS
    // Trigger on authenticate.
    case VISITOR_AUTHENTICATE
    // Trigger on unAuthenticate.
    case VISITOR_UNAUTHENTICATE
    // Trigger on sending Hit.
    case VISITOR_SEND_HIT
    // Trigger on sending activate.
    case VISITOR_SEND_ACTIVATE
    // Http call.
    case HTTP_CALL
    // Trigger when the bucketing route responds with code 200.
    case SDK_BUCKETING_FILE
    // Trigger when the bucketing route responds with error.
    case SDK_BUCKETING_FILE_ERROR
    // Trigger when the campaigns route responds with an error.
    case GET_CAMPAIGNS_ROUTE_RESPONSE_ERROR
    // Trigger when a batch request failed.
    case SEND_BATCH_HIT_ROUTE_RESPONSE_ERROR
    // Trigger when a activate request failed.
    case SEND_ACTIVATE_HIT_ROUTE_ERROR
    // Trigger when the Flag.getValue method is called and no flag is found.
    case GET_FLAG_VALUE_FLAG_NOT_FOUND
    // Trigger when the Flag.visitorExposed method is called and no flag is found.
    case VISITOR_EXPOSED_FLAG_NOT_FOUND
    // Trigger when the Flag.visitorExposed method is called and the flag value has a different type with default value.
    case GET_FLAG_VALUE_TYPE_WARNING
    // When a visitor attempts to expose a flag without calling the the getValue.
    case FLAG_EXPOSED_BEFORE_CALLING_VALUE_METHOD
    // Trigger when the SDK catches any other error but those listed here.
    case ERROR_CATCHED

    /// Emotions AI
    // It will be triggered when the route \accountSettings.json  has succeeded.
    case ACCOUNT_SETTINGS
    // It will be triggered when the route https://uc-info.flagship.io/
    case EMOTIONS_AI_SCORE
    // It will be triggered when EAI score is fetched from local storage.
    case EMOTIONS_AI_SCORE_FROM_LOCAL_CACHE
    // It will be triggered when the route https://uc-info.flagship.io/v1/ has failed.
    case EMOTIONS_AI_SCORE_ERROR
    // It will be triggered when a visitor event (Click, move) event is sent.
    case EMOTIONS_AI_VISITOR_EVENT
    // It will be triggered when a page view event is sent.
    case EMOTIONS_AI_PAGE_VIEW
    // It will be triggered when the sending of a visitor event (Click, scroll or move) event has failed.
    case EMOTIONS_AI_VISITOR_EVENT_ERROR
    // It will be triggered when the sending of page view event has failed.
    case EMOTIONS_AI_PAGE_VIEW_ERROR
    // It will be triggered when the collection of emotion AI events (Click, scroll or move) has begun.
    case EMOTIONS_AI_START_COLLECTING
    // It will be triggered when the collection of emotion AI events (Click, scroll or move) has stopped.
    case EMOTIONS_AI_STOP_COLLECTING
    // It will be triggered when the pulling of score has begun.
    case EMOTIONS_AI_START_SCORING
    // It will be triggered when no score has been calculated after the pulling max time is over.
    case EMOTIONS_AI_SCORING_FAILED
    // It will be triggered when  a score has been calculated during the pulling process.
    case EMOTIONS_AI_SCORING_SUCCESS
}
