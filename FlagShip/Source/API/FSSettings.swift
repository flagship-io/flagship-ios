//
//  FSSettings.swift
//  Flagship
//
//  Created by Adel Ferguen on 08/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

let FSEmmotionAIScoreKey = "EmmotionAIScoreKey"
// TODO: remove static envid value
class FSSettings {
    var session: URLSession = .init(configuration: URLSessionConfiguration.default)

    init() {}
    /// Get source on start the sdk
    /// - Parameter completion: block completion
    func fetchRessources(envId: String, completion: @escaping (FSExtras?, Error?) -> Void) {
        guard let url = URL(string: String(format: FSSettingsURL, envId)) else {
            return completion(nil, FlagshipError(message: "Invalid URL", type: .badRequest, code: 500))
        }
        self.session.dataTask(with: url) { data, _, _ in

            do {
                if let aData = data {
                    let accountSettingsObject = try JSONDecoder().decode(FSExtras.self, from: aData)
                    completion(accountSettingsObject, nil)
                }
            } catch {
                completion(nil, FlagshipError(message: error.localizedDescription, type: .internalError, code: 500))
            }
        }.resume()
    }

    /// Get Score from uc-info.flagship.io
    /// - Parameters:
    ///   - visitorId: String visitorId
    ///   - completion: block completion
    func fetchScore(visitorId: String, completion: @escaping (String?, Int) -> Void) {
        guard let getScoreUrl = URL(string: String(format: fetchEmotionAIScoreURL, Flagship.sharedInstance.envId ?? "", visitorId)) else {
            /// The Url creation failed
            print("No Score found for this vsitor - in server API")
            completion(nil, -1)
            return
        }

        print("Will ask for Score in server API :  \(getScoreUrl)")
        self.session.dataTask(with: getScoreUrl) { data, response, _ in
            if let response {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        print("Empty Content - Status Code:\(httpResponse.statusCode)")
                        completion(nil, httpResponse.statusCode)
                    } else if httpResponse.statusCode == 200 {
                        do {
                            if let aData = data {
                                let scoreObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]
                                if let segmentDico = scoreObject["eai"] as? [String: String] {
                                    if let score = segmentDico["eas"] {
                                        print(" @@@@@@@@@@@@@ Your current score is: \(score ?? "NO score found in remote API") @@@@@@@@@@@@@@@@@@@@")
                                        completion(score, httpResponse.statusCode)
                                        return
                                    }
                                }
                            }
                            print("No Score found for this vsitor - in server API")
                            completion(nil, httpResponse.statusCode)
                        } catch {
                            print("Errro on fetching score: \(error.localizedDescription)")
                            completion(nil, httpResponse.statusCode)
                        }

                    } else {
                        // Unknown error
                        print("Unknown error: \(httpResponse.statusCode)")
                        completion(nil, httpResponse.statusCode)
                    }
                }
            }
        }.resume()
    }

//    // Save the score locally
//    private class func getSocreFromLocal() -> String? {
//        UserDefaults.standard.string(forKey: FSEmmotionAIScoreKey)
//    }
//
//    private class func setSocreFromLocal(score: String) {
//        UserDefaults.standard.set(score, forKey: FSEmmotionAIScoreKey)
//    }
}
