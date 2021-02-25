//
//  FSConstant.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation


/// Universaal End Point
internal let FlagshipUniversalEndPoint = "https://decision.flagship.io/v2/"



/// XApi key
internal let FSX_Api_Key   =  "x-api-key"


/// Sdk name platforme ex : iOS
internal let FSX_SDK_Client   =   "x-sdk-client"

/// Sdk version ex: 2.0.1
internal let FSX_SDK_Version   =  "x-sdk-version"

/// platforme name

internal let FS_iOS = "iOS"



 
internal var FlagShipEndPoint :String {
    
     return FlagshipUniversalEndPoint
}

///// GET CAMPAIGNS /////////////////////////////////
/// Since version 1.2.1, we added a new parameter in campaign exposeAllKeys, in order to expose all keys in the original
/// Since version 1.2.2 we added sendContextEvent=false as parma in the route , those keys will be sent by the synchronize function 
internal let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns?exposeAllKeys=true&sendContextEvent=false"


///// ACTIVATE ///////////////
internal let FSActivate = FlagShipEndPoint + "activate"


///////////// ARIANE ////////////////////////////////
internal let FSDATA_ARIANE = "https://ariane.abtasty.com"



/////////////// GET SCRIPT ////////////////////////

internal let FSGetScript = "https://cdn.flagship.io/%@/bucketing.json"


/////// Upload all keys/values //////////////////

internal let FSSendKeyValueContext = FlagShipEndPoint + "%@/events"





