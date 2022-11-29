//
//  FSService.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

internal class FSService {
    
    /// clientId
    var envId: String
    /// apiKey
    var apiKey: String
    /// visitorId
    var visitorId:String
    /// anonymousId
    var anonymousId: String?
    
    internal var timeOutServiceForRequestApi = FSTimeoutRequestApi
    
    internal var serviceSession: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    
    /// Init service
    init(_ envId:String, _ apiKey:String, _ visitorId:String, _ anonymousId:String? = nil){
        /// Set client Id
        self.envId = envId
        /// Set apiKey
        self.apiKey = apiKey
        /// set visitorId
        self.visitorId = visitorId
    }
    
    

    /// Get campaign
    func getCampaigns(_ currentContext: [String: Any],hasConsented:Bool,onGetCampaign:@escaping(FSCampaigns?, Error?) -> Void){
        
        // Create param with visitor and currentContext
        let params: NSMutableDictionary = ["visitor_id": visitorId , "context": currentContext, "trigger_hit": false]
        // if anonymousId is not nil ===> add it to params
        if let aId = anonymousId {
            params.setValue(aId, forKey: "anonymousId")
        }
        // Add the consent param
        params.setValue(hasConsented ? true: false, forKey: VISITOR_CONSENT)
        do {
            
            guard let getUrl = URL(string: String(format: FSGetCampaigns, envId))else {
                
                /// The Url creation failed
                onGetCampaign(nil, FSError(codeError: 400, kind: .badRequest))
                return
            }
            
            FlagshipLogManager.Log(level: .DEBUG, tag: .CAMPAIGNS, messageToDisplay: FSLogMessage.GET_CAMPAIGN_URL("\(getUrl)"))
           
            let dataToPost = try JSONSerialization.data(withJSONObject: params, options: [])
            FlagshipLogManager.Log(level: .DEBUG, tag: .CAMPAIGNS, messageToDisplay:FSLogMessage.GET_CAMPAIGN((dataToPost.prettyPrintedJSONString ?? "Error to get pretty json")as String))

            sendRequest(getUrl, type: .Campaign, data: dataToPost) { responseData, error in
                
                if(error != nil){
                    
                    onGetCampaign(nil,error)
                    
                }else{
                    
                    let decode = JSONDecoder()
                    do {
                        /// Print response json before for debug
                        FlagshipLogManager.Log(level: .INFO, tag: .CAMPAIGNS, messageToDisplay:FSLogMessage.GET_CAMPAIGN_RESPONSE("\(responseData?.prettyPrintedJSONString ?? "Error on print jsonString")"))
                        let deocodedObject = try decode.decode(FSCampaigns.self, from: responseData ?? Data())
                        onGetCampaign(deocodedObject, nil)
                    }catch{onGetCampaign(nil,error)}
                }
            }
        }catch{
            onGetCampaign(nil,error)
        }
        

    }
    
    /// Activate
    func activate(_ activateInfos:[String:Any],onActivate:@escaping(Error?) -> Void){
        
        /// Create data
        do {
            let dataToPost = try JSONSerialization.data(withJSONObject: activateInfos, options: [])
            /// Create url
            if let activateUrl = URL(string: FSActivate){
                
                sendRequest(activateUrl, type: .Activate, data: dataToPost) { data, error in
                    
                    if (error != nil){
                        onActivate(error)
                    }else{
                        onActivate(nil)
                    }
                }
            }
            
        }catch{
            FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .ACTIVATE, messageToDisplay:FSLogMessage.ERROR_ON_DECODE_JSON)        }
    }
    
    /// Send All keys/values for the context
    /// - Parameter currentContext: dictionary that contain this infos

    func sendkeyValueContext(_ currentContext: [String: Any]) {
        
        do {
            
            var aCuurrentContext: [String: Any] = currentContext
            /// Remove the ALL_USERS
            aCuurrentContext.removeValue(forKey: ALL_USERS)

            let params: NSMutableDictionary = ["visitor_id": self.visitorId , "data": aCuurrentContext, "type": "CONTEXT"]

            let data = try JSONSerialization.data(withJSONObject: params, options: [])

            if let urlKeyCtx =  URL(string: String(format: FSSendKeyValueContext, self.envId)) {

                var uploadKeyValueCtxRqst: URLRequest = URLRequest(url: urlKeyCtx)

                /// Add headers client and version
                uploadKeyValueCtxRqst.addValue(FS_iOS, forHTTPHeaderField: FSX_SDK_Client)
                uploadKeyValueCtxRqst.addValue(FlagShipVersion, forHTTPHeaderField: FSX_SDK_Version)
                uploadKeyValueCtxRqst.httpMethod = "POST"
                uploadKeyValueCtxRqst.httpBody = data
                uploadKeyValueCtxRqst.addValue("application/json", forHTTPHeaderField: "Accept")
                
                
                /// Send the request
                sendRequest(urlKeyCtx, type: .KeyContext, data: data) { data, error in
                    
                    if error == nil {
                        
                        FlagshipLogManager.Log(level: .DEBUG, tag: .UPDATE_CONTEXT, messageToDisplay:FSLogMessage.SUCCESS_ON_SEND_KEYS)
                    }else{
                        
                        FlagshipLogManager.Log(level: .DEBUG, tag: .UPDATE_CONTEXT, messageToDisplay:FSLogMessage.FAILED_ON_SEND_KEYS)
                    }
                    
                }
            }
        }
        catch {
            
            FlagshipLogManager.Log(level: .DEBUG, tag: .PARSING, messageToDisplay:FSLogMessage.ERROR_ON_SERIALIZE)
        }
    }
        
}
