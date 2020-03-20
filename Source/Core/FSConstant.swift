//
//  FSConstant.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation
 

//internal let FlagShipEndEurope    = "https://decision-api.flagship.io/v1/"

/// Pre Prod
internal let FlagShipEndEurope  = "https://decisionapi.preprod.internal.flagship.io/v1/"


 /// New endpoint for apac
internal let FlagShipEndApac = "https://decision.flagship.io/v2/"


/// XApi key
internal let FSX_Api_Key   =  "x-api-key"


 
internal var FlagShipEndPoint :String {
    
    if ((Flagship.sharedInstance.service.apacRegion) != nil){
        
          return FlagShipEndApac

    }else{
        
          return FlagShipEndEurope
    }
    
}

///// GET CAMPAIGNS /////////////////////////////////
/// Since version 1.2.1, we added a new parameter in campaign exposeAllKeys, in order to expose all keys in the original
internal let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns?exposeAllKeys=true"


///// ACTIVATE ///////////////
internal let FSActivate = FlagShipEndPoint + "activate"


///////////// ARIANE ////////////////////////////////
internal let FSDATA_ARIANE = "https://ariane.abtasty.com"



/////////////// GET SCRIPT ////////////////////////

internal let FSGetScript = "https://cdn.flagship.io/%@/bucketing.json"



