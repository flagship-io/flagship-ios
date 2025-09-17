//
//  FSSettings.swift
//  Flagship
//
//  Created by Adel Ferguen on 08/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

let FSEmmotionAIScoreKey = "EmmotionAIScoreKey"
class FSSettings {
    var session: URLSession = .init(configuration: URLSessionConfiguration.default)

    init() {}
    /// Get source on start the sdk
    /// - Parameter completion: block completion
    func fetchRessources(envId: String, completion: @escaping (FSExtras?, Error?) -> Void) {
        guard let url = URL(string: String(format: FSSettingsURL, envId)) else {
            return completion(nil, FlagshipError(message: "Invalid URL", type: .badRequest, code: 500))
        }
        self.session.dataTask(with: url) { data, response, _ in

            do {
                if let aData = data {
                    let accountSettingsObject = try JSONDecoder().decode(FSExtras.self, from: aData)
                    completion(accountSettingsObject, nil)

                    // Update TroubleShooting
                    FSDataUsageTracking.sharedInstance.updateTroubleshooting(trblShooting: accountSettingsObject.accountSettings?.troubleshooting)

                    // TR on success
                    FSDataUsageTracking.sharedInstance.processTSHttp(crticalPointLabel: CriticalPoints.ACCOUNT_SETTINGS, response as? HTTPURLResponse, URLRequest(url: url), aData)
                }
            } catch {
                completion(nil, FlagshipError(message: error.localizedDescription, type: .internalError, code: 500))
                FSDataUsageTracking.sharedInstance.processTSEmotionsSettingsError(label: CriticalPoints.ACCOUNT_SETTINGS, response as? HTTPURLResponse, URLRequest(url: url))
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
            ///
            FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("No Score found for this vsitor - in EAI server"))
            completion(nil, -1)
            return
        }

        self.session.dataTask(with: getScoreUrl) { data, response, _ in
            if let response {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        // Clean code later
                        completion(nil, httpResponse.statusCode)
                    } else if httpResponse.statusCode == 200 {
                        do {
                            if let aData = data {
                                let scoreObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]
                                if let segmentDico = scoreObject["eai"] as? [String: String] {
                                    if let score = segmentDico["eas"] {
                                        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Your current EAI score is: \(score)"))

                                        completion(score, httpResponse.statusCode)

                                        FSDataUsageTracking.sharedInstance.processTSEmotionsScoreSuccess(visitorId: visitorId, anonymousId: nil, response: httpResponse, URLRequest(url: getScoreUrl), score)
                                        return
                                    }
                                }
                            }
                            FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("No Score found in the response from server"))
                            completion(nil, httpResponse.statusCode)
                        } catch {
                            FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Errro on fetching score: \(error.localizedDescription)"))
                            completion(nil, httpResponse.statusCode)
                        }

                    } else {
                        FSDataUsageTracking.sharedInstance.processTSEmotionsSettingsError(label: CriticalPoints.EMOTIONS_AI_SCORE_ERROR, httpResponse, URLRequest(url: getScoreUrl), data)

                        FlagshipLogManager.Log(level: .DEBUG, tag: .TRACKING, messageToDisplay: FSLogMessage.MESSAGE("Error on fetching score: \(httpResponse.statusCode)"))
                        completion(nil, httpResponse.statusCode)
                    }
                }
            }
        }.resume()
    }

 

    /// Read features configuration from local json file
    /// - Parameter completion: Completion handler with optional FSFeaturesConfiguration and error
    func readFeaturesConfiguration(completion: @escaping (FSFeatureConfiguration?, Error?) -> Void) {
        guard let featuresPath = Bundle.main.path(forResource: "features", ofType: "json") else {
            completion(nil, FlagshipError(message: "features.json file not found", type: .internalError, code: 404))
            return
        }

        do {
            let fileUrl = URL(fileURLWithPath: featuresPath)
            let data = try Data(contentsOf: fileUrl)
            let decoder = JSONDecoder()
            let features = try decoder.decode(FSFeatureConfiguration.self, from: data)
            completion(features, nil)
        } catch {
            completion(nil, FlagshipError(message: error.localizedDescription, type: .internalError, code: 500))
            FlagshipLogManager.Log(level: .ERROR,
                                   tag: .CONFIGURATION,
                                   messageToDisplay: FSLogMessage.MESSAGE("Error reading features configuration: \(error.localizedDescription)"))
        }
    }
}
