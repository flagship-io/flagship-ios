//
//  FSProfile.swift
//  FlagShip
//
//  Created by Adel on 23/10/2019.
//

import UIKit


  typealias TupleId = (fsUserId:String , customId:String?)

  class FSProfile: NSObject {
    
    var tupleId:TupleId
    
    init(_ customerVisitorId:String!) {
        
        if let fsId = FSGenerator.getFlagShipIdInCache() {
            
            tupleId.fsUserId = fsId
        }else{
            
            // Create FlagShip Id
            tupleId.fsUserId = FSGenerator.generateFlagShipId()
            // Save
            FSGenerator.saveFlagShipIdInCache(userId: tupleId.fsUserId)
        }
        
        tupleId.customId = customerVisitorId
    }
}
