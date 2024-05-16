//
//  FSService.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

class FSService {
    /// clientId
    var envId: String
    /// apiKey
    var apiKey: String
    /// visitorId
    var visitorId: String
    /// anonymousId
    var anonymousId: String?
    
    var timeOutServiceForRequestApi = FSTimeoutDecisionApi
    
    var serviceSession: URLSession = .init(configuration: URLSessionConfiguration.default)
    
    /// Init service
    init(_ envId: String, _ apiKey: String, _ visitorId: String, _ anonymousId: String? = nil) {
        /// Set client Id
        self.envId = envId
        /// Set apiKey
        self.apiKey = apiKey
        /// set visitorId
        self.visitorId = visitorId
    }
    
    /// Get campaign
    func getCampaigns(_ currentContext: [String: Any], hasConsented: Bool, onGetCampaign: @escaping (FSCampaigns?, Error?) -> Void) {
        // Create param with visitor and currentContext
        let params: NSMutableDictionary = ["visitor_id": visitorId, "context": currentContext, "trigger_hit": false]
        // if anonymousId is not nil ===> add it to params
        if let aId = anonymousId {
            params.setValue(aId, forKey: "anonymousId")
        }
        // Add the consent param
        params.setValue(hasConsented ? true : false, forKey: VISITOR_CONSENT)
        do {
            guard let getUrl = URL(string: String(format: FSGetCampaigns, envId)) else {
                /// The Url creation failed
                onGetCampaign(nil, FlagshipError(type: .badRequest, code: 400))
                return
            }
            FlagshipLogManager.Log(level: .DEBUG, tag: .CAMPAIGNS, messageToDisplay: FSLogMessage.GET_CAMPAIGN_URL("\(getUrl)"))
           
            let dataToPost = try JSONSerialization.data(withJSONObject: params, options: [])
            
            FlagshipLogManager.Log(level: .DEBUG, tag: .CAMPAIGNS, messageToDisplay: FSLogMessage.GET_CAMPAIGN((dataToPost.prettyPrintedJSONString ?? "Error to get pretty json") as String))

            sendRequest(getUrl, type: .Campaign, data: dataToPost) { responseData, error in
                
                if error != nil {
                    onGetCampaign(nil, error)
                    
                } else {
                    let decode = JSONDecoder()
                    do {
                        /// Display response json before for debug
                        FlagshipLogManager.Log(level: .INFO, tag: .CAMPAIGNS, messageToDisplay: FSLogMessage.GET_CAMPAIGN_RESPONSE("\(responseData?.prettyPrintedJSONString ?? "Error on display jsonString")"))
                        let deocodedObject = try decode.decode(FSCampaigns.self, from: responseData ?? Data())
                        onGetCampaign(deocodedObject, nil)
                    } catch {
                        onGetCampaign(nil, error)
                    }
                }
            }
        } catch {
            onGetCampaign(nil, error)
        }
    }
    
    /// Activate
    func activate(_ activateInfos: [String: Any], onActivate: @escaping (Error?) -> Void) {
        /// Create data
        do {
            let dataToPost = try JSONSerialization.data(withJSONObject: activateInfos, options: [])
            /// Create url
            if let activateUrl = URL(string: FSActivate) {
                sendRequest(activateUrl, type: .Activate, data: dataToPost) { _, error in
                    
                    if error != nil {
                        onActivate(error)
                    } else {
                        onActivate(nil)
                    }
                }
            }
            
        } catch {
            FlagshipLogManager.Log(level: .EXCEPTIONS, tag: .ACTIVATE, messageToDisplay: FSLogMessage.ERROR_ON_DECODE_JSON)
            FSDataUsageTracking.sharedInstance.processTSCatchedError(v: nil, error: FlagshipError(message: "Error on Activate"))
        }
    }
}
