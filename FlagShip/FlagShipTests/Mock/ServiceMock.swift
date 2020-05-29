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
        
        /// read the data from the file and fill the campaigns
        do {
            
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            let scriptObject = try JSONDecoder().decode(FSCampaigns.self, from: data)
            
            onGetCampaign(scriptObject,nil)
        }catch{
            
            print("error")
        }
       
    }
    
    
     internal func getFSScriptMock(onGetScript: @escaping (FSBucket?, FlagshipError?) -> Void) {
        
        /// read the data from the file and fill the campaigns
        do {
            
            let testBundle = Bundle(for: type(of: self))

            guard let path = testBundle.url(forResource: "bucketMock", withExtension: "json") else { return  }
            
            let data = try Data(contentsOf: path, options:.alwaysMapped)
            
            let scriptObject = try JSONDecoder().decode(FSBucket.self, from: data)

            onGetScript(scriptObject,nil)
            
        }catch{
            
            print("error")
        }
        
        
        
    }
    
    
    
    
    

}
