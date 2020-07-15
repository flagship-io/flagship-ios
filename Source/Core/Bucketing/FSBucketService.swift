//
//  FSBucketService.swift
//  FlagShip-framework
//
//  Created by Adel on 18/11/2019.
//

import Foundation



let FSLastModified        = "Last-Modified"
let FSLastModified_Key    = "FSLastModifiedScript"
let FS_If_ModifiedSince   = "If-Modified-Since"



/// :nodoc:
internal extension ABService {
    
    func getFSScript(onGetScript:@escaping(FSBucket?, FlagshipError?)->Void){
        
        if let urlScript = URL(string:String(format: FSGetScript, self.clientId)) {
            
            var request:URLRequest = URLRequest(url: urlScript)
            
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
                    
                    if let responseData = data {
                        
                        do {
                            
                            let scriptObject = try JSONDecoder().decode(FSBucket.self, from: responseData)
                            
                            // Print Json response
                            let dico = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
                            
                            FSLogger.FSlog("The script bucketing is : \(dico)", .Campaign)
                            onGetScript(scriptObject, nil)
                            
                            /// Save bucket script
                            self.cacheManager.saveBucketScriptInCache(data)
                            
                        }catch{
                            
                            onGetScript(nil, .CetScriptError)
                        }
                        
                        
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
    }
    
    
    
    /// Send All keys/values for the context
    /// - Parameter currentContext: dictionary that contain this infos
    
    func sendkeyValueContext(_ currentContext:Dictionary <String,Any>){
        
        do{
            
            /// Filter the dictionary before uploading ...
            var aCuurrentContext:[String:Any] = currentContext
            /// Remove the ALL_USERS
            aCuurrentContext.removeValue(forKey: ALL_USERS)
            
            let params:NSMutableDictionary = ["visitor_id":visitorId ?? "" , "data":aCuurrentContext, "type": "CONTEXT"]
            
            let data = try JSONSerialization.data(withJSONObject: params, options:[])
            
            if let urlKeyCtx =  URL(string:String(format: FSSendKeyValueContext, clientId)) {
                
                var uploadKeyValueCtxRqst:URLRequest = URLRequest(url: urlKeyCtx)
                
                uploadKeyValueCtxRqst.httpMethod = "POST"
                uploadKeyValueCtxRqst.httpBody = data
                uploadKeyValueCtxRqst.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                uploadKeyValueCtxRqst.addValue("application/json", forHTTPHeaderField: "Accept")
                
                /// Add x-api-key for apacOption
                
                if (apacRegion != nil){
                    
                    uploadKeyValueCtxRqst.addValue(apacRegion?.apiKey ?? "", forHTTPHeaderField: FSX_Api_Key)
                }
                
                
                let session = URLSession(configuration:URLSessionConfiguration.default)
                
                session.dataTask(with: uploadKeyValueCtxRqst) { (responseData, response, error) in
                    
                    if (error == nil){
                        
                        let httpResponse = response as? HTTPURLResponse
                        
                        switch (httpResponse?.statusCode){
                        case 200, 204:
                            
                            FSLogger.FSlog("Success on sending keys / values context", .Network)
                            break
                        default:
                            FSLogger.FSlog("Error on sending keys / values context", .Network)
                        }
                    }else{
                        
                        FSLogger.FSlog("Error on sending keys / values context", .Network)

                    }
                    
                }.resume()
                
                
                
            }
            
        }catch{
            
            FSLogger.FSlog("error on serializing json", .Network)
        }
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


