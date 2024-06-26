//
//  FSConstant.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation

/// Universaal End Point
let FlagshipUniversalEndPoint = "https://decision.flagship.io/v2/"

// internal let FlagshipUniversalEndPoint =  "https://decision-staging.flagship.io/v2/"

/// XApi key
let FSX_Api_Key = "x-api-key"

/// Sdk name platforme ex : iOS
let FSX_SDK_Client = "x-sdk-client"

/// Sdk version ex: 2.0.1
let FSX_SDK_Version = "x-sdk-version"

/// platforme name

let FS_iOS = "iOS"

var FlagShipEndPoint: String {
    return FlagshipUniversalEndPoint
}

///// GET CAMPAIGNS /////////////////////////////////
/// Since version 1.2.1, we added a new parameter in campaign exposeAllKeys, in order to expose all keys in the original
/// Since version 1.2.2 we added sendContextEvent=false as parma in the route , those keys will be sent by the synchronize function
/// internal let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns?exposeAllKeys=true&sendContextEvent=false"

/// remove "sendContextEvent=false" with in refractoring
let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns?exposeAllKeys=true&extras[]=accountSettings"

/// Add this part when the user don't consent
let VISITOR_CONSENT = "visitor_consent"

///// ACTIVATE ///////////////
let FSActivate = FlagShipEndPoint + "activate" // TODO Change 

///////////// ARIANE ////////////////////////////////
// internal let FSDATA_ARIANE = "https://ariane.abtasty.com"

let EVENT_TRACKING = "https://events.flagship.io"

/////////////// GET SCRIPT ////////////////////////

let FSGetScript = "https://cdn.flagship.io/%@/bucketing.json"

/////// Upload all keys/values //////////////////

let FSSendKeyValueContext = FlagShipEndPoint + "%@/events"

let FSConsentAction = "fs_consent"

// Troubleshooting

let FSTroubleshootingUrlString = EVENT_TRACKING + "/troubleshooting"

// Developer usage
let FSDeveloperUsageUrlString = EVENT_TRACKING + "/analytics"

// Local Notification

let FSBucketingScriptNotification =  "onGettingBucketScript"
