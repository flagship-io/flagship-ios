//
//  ABService.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation

//  This class will represent the service , here will be able to post the data



internal class ABService {
    
    var clientId:String!
    
    var visitorId:String?
    
    var offLineTracking:FSOfflineTracking!
    
    var cacheManager:FSCacheManager!
    
    
    init(_ clientId:String, _ visitorId:String) {
        
        self.clientId = clientId
        
        self.visitorId = visitorId
        
        offLineTracking = FSOfflineTracking(self)
        
        cacheManager = FSCacheManager()
     }
    
    

    
    func getCampaigns(_ currentContext:Dictionary <String,Any>,  onGetCampaign:@escaping(FSCampaigns?, FlagshipError?)->Void){
        
        do {
            let params:NSMutableDictionary = ["visitor_id":visitorId ?? "", "context":currentContext, "trigger_hit":false]
            let data = try JSONSerialization.data(withJSONObject: params, options:[])
            
            var request:URLRequest = URLRequest(url: URL(string:String(format: FSGetCampaigns, clientId))!)
            request.httpMethod = "POST"
            request.httpBody = data
            
            request.timeoutInterval = 10
            
 
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            
            let session = URLSession(configuration:URLSessionConfiguration.default)
            
            session.dataTask(with: request) { (responseData, response, error) in
                
                if (error == nil){
                    
                    let httpResponse = response as? HTTPURLResponse
                    switch (httpResponse?.statusCode){
                        
                    case 200:
                        
                        if(responseData != nil){
                            
                            do {
                                
                                let decoder = JSONDecoder()
                                let objectDecoded = try decoder.decode(FSCampaigns.self, from: responseData!)
                                
                                
                                // Print Json response
                               let dico = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                               FSLogger.FSlog("getCampaigns is : \(dico)", .Campaign)
                                
                                /// Save also the data in the Directory
                                self.cacheManager.saveCampaignsInCache(responseData)
                                onGetCampaign(objectDecoded, nil)
                                
                            } catch {
                                
                                onGetCampaign(nil, FlagshipError.GetCampaignError)
                                print(error.localizedDescription)
                            }
                        }
                        
                        break
                    case 403:
                        onGetCampaign(nil, FlagshipError.GetCampaignError)
                        
                    case 400:
                        onGetCampaign(nil, FlagshipError.GetCampaignError)
                    default:
                        FSLogger.FSlog("Rrror on get campaign", .Network)
                    }
                }else{
                    
                    onGetCampaign(nil, FlagshipError.GetCampaignError)
                }
                
                }.resume()
            
        }catch{
            
            FSLogger.FSlog("error on serializing json", .Network)
        }
    }
    
    
    
    // Activate variation
    public func activateCampaignRelativetoKey(_ key:String, _ campaign:FSCampaigns){
        
        // Before send Activate
        // prepare somme actions
        
        guard var infosTrack = campaign.getRelativeInfoTrackForValue(key)else{
            
            FSLogger.FSlog(" Failed to send activate .... The key doesn't exist !!!", .Campaign)

            return
        }
        
        do {
            // Set Visitor Id
            infosTrack.updateValue(visitorId ?? "", forKey: "vid")
            // Set Client Id
            infosTrack.updateValue(clientId, forKey: "cid")
            
            let data = try JSONSerialization.data(withJSONObject: infosTrack, options:[])
            
            // here we have data ready, check the connexion before
            
            if (self.offLineTracking.isConnexionAvailable() == false){
                
                self.offLineTracking.saveActivateEvent(data)
                
                FSLogger.FSlog("Activate will be send in the next lauch when connexion will available", .Network)
                return
            }
            
            var request:URLRequest = URLRequest(url: URL(string:FSActivate)!)
            request.httpMethod = "POST"
            request.httpBody = data
           
            let session = URLSession(configuration:URLSessionConfiguration.default)
            session.dataTask(with: request) { (responseData, response, error) in
                
                if (error == nil){
                    
                    let httpResponse = response as? HTTPURLResponse
                    
                    switch (httpResponse?.statusCode){
                        
                    case 200,204:
                        
                        FSLogger.FSlog("The activate is sent with success ", .Network)
                        
                    default:
                        FSLogger.FSlog("Error, Activate Request", .Network)
                        
                    }
                }else{
                    
                    FSLogger.FSlog(error!.localizedDescription, .Network)
                }
                
                }.resume()
            
        }catch{
            
            FSLogger.FSlog("Bad Request", .Network)

        }
    }
    
}







