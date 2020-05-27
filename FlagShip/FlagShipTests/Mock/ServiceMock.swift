//
//  ServiceMock.swift
//  FlagshipTests
//
//  Created by Adel on 26/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
@testable import Flagship


class ServiceMock:ABService {
    
    
    override func getCampaigns(_ currentContext: Dictionary<String, Any>, onGetCampaign: @escaping (FSCampaigns?, FlagshipError?) -> Void) {
        
        
        onGetCampaign(nil,nil)
    }
    
    
    
    
    

}
