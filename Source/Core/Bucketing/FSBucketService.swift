//
//  FSBucketService.swift
//  FlagShip-framework
//
//  Created by Adel on 18/11/2019.
//

import UIKit



let FSLastModified        = "Last-Modified"
let FSLastModified_Key    = "FSLastModifiedScript"
let FS_If_ModifiedSince   = "If-Modified-Since"




internal extension ABService {
    
    func getFSScript(onGetScript:@escaping(FSBucket?, FlagshipError?)->Void){
        
        var request:URLRequest = URLRequest(url: URL(string:String(format: FSGetScript, self.clientId))!)
        
        // Manage id last modified
        
        let dateModified: String? = UserDefaults.standard.value(forKey:FSLastModified_Key) as? String
        
        if (dateModified != nil){
            
            request.setValue(dateModified , forHTTPHeaderField:FS_If_ModifiedSince)
        }
        
        let session = URLSession(configuration:URLSessionConfiguration.ephemeral)
        
        session.dataTask(with: request) { (data, response, error) in
            
            let httpResponse = response as? HTTPURLResponse
            
            switch httpResponse?.statusCode {
                
            case 200:
                /// Manage last modified
                self.manageLastModified(httpResponse)
                
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
                
                break
                
            case 304:
                /// Read the script from the cache
                FSLogger.FSlog("Status 304, No need to download the bucketing script", .Campaign)
                onGetScript(nil, .CetScriptError)

                break
                
            default:
                break
            }
        }.resume()
    }
    
    
    
    private func manageLastModified(_ response: HTTPURLResponse?){
        
        guard let lastModified = response?.allHeaderFields[FSLastModified] else{
            
            FSLogger.FSlog("Last Modified missing from headers", .Campaign)
            return
        }
        
        // Save this date into userDefault
        UserDefaults.standard.set(lastModified, forKey:FSLastModified_Key)
    }
}


