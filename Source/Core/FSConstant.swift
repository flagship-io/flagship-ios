//
//  FSConstant.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation

/// https://decision-api.canarybay.com/<ENVIRONMENT_ID>/campaigns

 internal let FlagShipEndEurope    = "https://decision-api.flagship.io/v1/"


 /// New endpoint for apac
internal let FlagShipEndApac = "https://decision-api.flagship.io/v1/"


/// XApi key
internal let FSX_Api_Key   =  "x-api-key"


 
internal var FlagShipEndPoint :String {
    
    if ((Flagship.sharedInstance.service.apacOption) != nil){
        
          return FlagShipEndApac

    }else{
        
          return FlagShipEndEurope
    }
    
}

///// GET CAMPAIGNS /////////////////////////////////
internal let FSGetCampaigns = FlagShipEndPoint + "%@/campaigns"


///// ACTIVATE ///////////////
internal let FSActivate = FlagShipEndPoint + "activate"


///////////// ARIANE ////////////////////////////////
internal let FSDATA_ARIANE = "https://ariane.abtasty.com"



/////////////// GET SCRIPT ////////////////////////

internal let FSGetScript = "https://cdn.flagship.io/%@/bucketing.json"



