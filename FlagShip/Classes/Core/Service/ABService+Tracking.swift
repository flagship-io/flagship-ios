//
//  ABService+Tracking.swift
//  FlagShip
//
//  Created by Adel on 12/08/2019.
//

import Foundation

internal extension ABService{
    
    
     func sendTracking< T: FSTrackingProtocol>(_ event:T){
        
        self.sendEvent(event)
    }
    
    
    ////////////////////: Send Event ...///////////////////////////////////////////////:
    
     func sendEvent< T: FSTrackingProtocol>(_ event:T){
        
        /// Check if the connexion is available
        
        if (self.offLineTracking.isConnexionAvailable() == false ){
            
            FSLogger.FSlog("The connexion is not available ..... The event will be saved in Data Base", .Network)
            
            self.offLineTracking.saveEvent(event)
            
            return
        }
        
        do {
            
            FSLogger.FSlog(String(format: "Sending : ....... %@", event.bodyTrack.debugDescription), .Network)
            let data = try JSONSerialization.data(withJSONObject:event.bodyTrack as Any, options:.prettyPrinted)
            
            var request:URLRequest = URLRequest(url: URL(string:FSDATA_ARIANE)!)
           
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession(configuration:URLSessionConfiguration.default)
            
            session.dataTask(with: request) { (responseData, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                
                switch (httpResponse?.statusCode){
                    
                case 200:
                    FSLogger.FSlog("Event sent with success", .Network)
                    break
                case 403:
                    
                    break
 
                case 400:
                    
                    break
                 default:
                    FSLogger.FSlog("Error on send Event", .Network)
                }
                
                }.resume()
            
        }catch{
            
            FSLogger.FSlog("Error serialize  event ", .Network)
        }
        
    }
    
}
