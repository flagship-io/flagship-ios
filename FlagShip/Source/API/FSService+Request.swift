//
//  FSService+Request.swift
//  Flagship
//
//  Created by Adel on 05/10/2021.
//

import Foundation

internal extension FSService {
    
    //////// private
    enum FSRequestType:Int{
        
        case Campaign  = 1
        case Activate
        case Tracking
        case KeyContext
    }
    
     func sendRequest(_ pUrl:URL, type:FSRequestType,data:Data? = nil, onCompleted:@escaping(Data?, Error?) -> Void){
         
        var request = URLRequest(url: pUrl, timeoutInterval: timeOutServiceForRequestApi)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
         request.httpBody = data
         /// Add headers client and version
         request.addValue(FS_iOS, forHTTPHeaderField: FSX_SDK_Client)
         /// SDK Version
         request.addValue(FlagShipVersion, forHTTPHeaderField: FSX_SDK_Version)
         
        switch type {
        case .Campaign:
            /// Add x-api-key
            request.addValue(apiKey, forHTTPHeaderField: FSX_Api_Key)
            break
        default:
            break
        }
        
        
        serviceSession.dataTask(with: request) { data, response, error in
            
            if (error != nil){
                
                onCompleted(nil,error)
            }else{
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        
                        onCompleted(data, nil)
                        
                    }else{
                        
                        onCompleted(nil, FSError(codeError: httpResponse.statusCode, kind: .sendRequest))
                    }
                }else{
                    onCompleted(nil, FSError(codeError: 400, kind: .sendRequest))
                }
            }
        }.resume()
    }
}
