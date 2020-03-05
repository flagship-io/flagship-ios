//
//  FSBucketService.swift
//  FlagShip-framework
//
//  Created by Adel on 18/11/2019.
//

import UIKit

internal extension ABService {
    
     func getFSScript(onGetScript:@escaping(FSBucket?, FlagshipError?)->Void){
        
        let request:URLRequest = URLRequest(url: URL(string:String(format: FSGetScript, self.clientId))!)
        
        let session = URLSession(configuration:URLSessionConfiguration.ephemeral)
        
        session.dataTask(with: request) { (data, response, error) in
            
            
            if (error == nil){
                
                let httpResponse = response as? HTTPURLResponse
                
                if (httpResponse?.statusCode == 200){
                    
                    
 
 
                    let decoder = JSONDecoder()
                    
                    do {
                        let scriptObject = try decoder.decode(FSBucket.self, from: data!)
                        
                         // Print Json response
                        let dico = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        FSLogger.FSlog("getCampaigns is : \(dico)", .Campaign)
                        
                        onGetScript(scriptObject, nil)
                        
                        /// Save bucket script
                        self.cacheManager.saveBucketScriptInCache(data)
                        
                    }catch{
                        
                        onGetScript(nil, .CetScriptError)
                    }
                 }
            }else{
                
                onGetScript(nil, .CetScriptError)
            }
            
        }.resume()
    }

}
