//
//  ABService+Tracking.swift
//  FlagShip
//
//  Created by Adel on 12/08/2019.
//

import Foundation

extension ABService{
    
    
    
    public func sendTracking< T: FSTrackingProtocol>(_ event:T){
        
        
        switch event.type {
            
            
        case .PAGE:
            break
            
        case .VISITOR:
            break
            
            
        case .TRANSACTION:
            break
            
        case .ITEM:
            break
            
        case .EVENT:
            
            self.sendEvent(event as! FSEventTrack)
            break
            
        default: break
            
        }
    }
    
    
    ////////////////////: Send Event ...///////////////////////////////////////////////:
    
    internal func sendEvent(_ event:FSEventTrack){
        
        do {
            let data = try JSONSerialization.data(withJSONObject: event.bodyTrack as Any, options:[])
            
           print(" @@@@@@@@@@@@@@@ Send Event \( event.bodyTrack) @@@@@@@@@@@@@@@@@@@@@@@@@")
            
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
