//
//  FSService+Request.swift
//  Flagship
//
//  Created by Adel on 05/10/2021.
//

import Foundation

//////// private
enum FSRequestType: Int {
    // Fetch Camapign
    case Campaign = 1
    // On send Activate
    case Activate
    // On send hits for goal
    case Tracking
    // On sending context segment
    case KeyContext
    // Used for DataReport or Troubleshooting
    case DataUsage
    // Used for emotions view event
    case EmotionsView
    // Used For emotions visitor event
    case EmotionsVisitor
}

extension FSService {
    func sendRequest(_ pUrl: URL, type: FSRequestType, data: Data? = nil, onCompleted: @escaping (Data?, Error?) -> Void) {
        var request = URLRequest(url: pUrl, timeoutInterval: (type == .Campaign) ? timeOutServiceForRequestApi : FSTimeoutRequest)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"

        request.httpBody = data
        /// Add headers client and version
        request.addValue(FS_iOS, forHTTPHeaderField: FSX_SDK_Client)
        /// SDK Version
        request.addValue(FlagShipVersion, forHTTPHeaderField: FSX_SDK_Version)

        /// Tempo
        ///
        request.setValue("CustomUserAgentString", forHTTPHeaderField: "User-Agent")
        /// End Tempo

        switch type {
        case .Campaign:
            /// Add x-api-key
            request.addValue(apiKey, forHTTPHeaderField: FSX_Api_Key)
        default:
            break
        }
        serviceSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    onCompleted(nil, error)
                    FSDataUsageTracking.sharedInstance.processTSHttpError(requestType: type, response as? HTTPURLResponse, request, data)
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        if (200 ... 299).contains(httpResponse.statusCode) {
                            onCompleted(data, nil)

                        } else {
                            FSDataUsageTracking.sharedInstance.processTSHttpError(requestType: type, response as? HTTPURLResponse, request, data)
                            onCompleted(nil, FlagshipError(type: .sendRequest, code: httpResponse.statusCode))
                        }
                    } else {
                        onCompleted(nil, FlagshipError(type: .sendRequest, code: 400))
                    }
                }
            }

        }.resume()
    }
}
