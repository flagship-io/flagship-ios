//
//  FSCacheManager.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation

class FSCacheManager {
    
    
    // Manager File
    var fileManager:FileManager = FileManager.default
    
    init() {
        
        
    }
    
    
    // Get All Event
    func readCampaignFromCache()->FSCampaigns?{
        
        return nil
    }
    
    
    
    // Write Campaign on Directory
    func saveCampaignsInCache(_ campaigns:FSCampaigns){
        
    }
}
