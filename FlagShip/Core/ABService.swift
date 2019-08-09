//
//  ABService.swift
//  Flagship
//
//  Created by Adel on 02/08/2019.
//

import Foundation

//  This class will represent the service , here will be able to post the data


class ABService {
    
    var clientId:String!
    
    var visitorId:String!

    
    init(_ clientId:String, _ visitorId:String) {
        
        self.clientId = clientId
        
        self.visitorId = visitorId
    }
    
    
    
    
    
    func getCampaigns(_ currentContext:Dictionary <String,Any>,  onGetCampaign:@escaping(FSCampaigns?, FlagshipError?)->Void){
        
        do {
            
            let params:NSMutableDictionary = ["visitor_id":visitorId, "context":currentContext]
            let data = try JSONSerialization.data(withJSONObject: params, options:[])
            
            var request:URLRequest = URLRequest(url: URL(string:String(format: FSGetCampaigns, clientId))!)
            request.httpMethod = "POST"
            request.httpBody = data
            
 
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            
            let session = URLSession(configuration:URLSessionConfiguration.default)
            
            session.dataTask(with: request) { (responseData, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                
                switch (httpResponse?.statusCode){
                    
                case 200:
                    
                    if(responseData != nil){
                        
                        do {
                            
                            let decoder = JSONDecoder()
                            let objectDecoded = try decoder.decode(FSCampaigns.self, from: responseData!)
                            onGetCampaign(objectDecoded, nil)
                            
                        } catch {
                            
                            print(error)
                        }
                    }
                    
                    break
                case 403:
                    onGetCampaign(nil, FlagshipError.GetCampaignError)
                    
                case 400:
                    onGetCampaign(nil, FlagshipError.GetCampaignError)
                default:
                    print("none")
                }
                
                }.resume()
            
        }catch{
            
            print("error on serializing json")
        }
    }
    
    
    
    // Activate variation
    
    public func activateCampaignRelativetoKey(_ key:String){
        
        
        
    }
    
}







