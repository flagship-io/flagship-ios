//
//  ABService+Tracking.swift
//  FlagShip
//
//  Created by Adel on 12/08/2019.
//

import Foundation

extension ABService{
    
    
    public func sendTracking< T: FSTrackingProtocol>(_ event:T){
        
        self.sendEvent(event)
    }
    
    
    ////////////////////: Send Event ...///////////////////////////////////////////////:
    
    internal func sendEvent< T: FSTrackingProtocol>(_ event:T){
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject:event.bodyTrack as Any, options:.prettyPrinted)
            
            let json = try? JSONSerialization.jsonObject(with: data, options:.allowFragments )

           print(" @@@@@@@@@@@@@@@ Send Event \(json) @@@@@@@@@@@@@@@@@@@@@@@@@")
            
            var request:URLRequest = URLRequest(url: URL(string:FSDATA_ARIANE)!)
           
            request.httpMethod = "POST"
            request.httpBody = data
            
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession(configuration:URLSessionConfiguration.default)
            
            session.dataTask(with: request) { (responseData, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                
                switch (httpResponse?.statusCode){
                    
                case 200:
                    
                    print("YESSSSSS.... EVENT SENT .....................")
                    break
                case 403:
                    
                    break
 
                case 400:
                    
                    break
                 default:
                    print("none")
                }
                
                }.resume()
            
        }catch{
            
            print("error on serializing json")
        }
        
    }
    
}
