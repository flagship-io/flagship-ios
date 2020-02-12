//
//  FSConstant.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation

// https://decision-api.canarybay.com/<ENVIRONMENT_ID>/campaigns



internal let FlagShipEndPoint = "https://decision-api.flagship.io/v1/"


///// GET CAMPAIGNS /////////////////////////////////
internal let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns"


///// ACTIVATE ///////////////
internal let FSActivate = FlagShipEndPoint + "activate"


///////////// ARIANE ////////////////////////////////
internal let FSDATA_ARIANE = "https://ariane.abtasty.com"



/////////////// GET SCRIPT ////////////////////////

internal let FSGetScript = "https://cdn.flagship.io/%@/bucketing.json"



