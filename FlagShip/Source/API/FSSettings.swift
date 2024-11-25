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
    // Get source on start the sdk
    class func fetchRessources(completion: @escaping ([String: Any]) -> Void) {
        /// Replace the url later
        let url = URL(string: "https://my.api.mockaroo.com/settings.json?key=d67200a0")!

        URLSession.shared.dataTask(with: url) { data, _, _ in

            do {
                if let aData = data {
                    let scriptObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]

                    completion(scriptObject)
                }

            } catch {
                print("Error on fetchRessources: \(error)")
                completion([:])
            }
        }.resume()
    }

    // Fetch the score locally or remotely
    class func fetchScore(visitorId: String, completion: @escaping (String?) -> Void) {
        guard let getScoreUrl = URL(string: String(format: fetchEmotionAIScoreURL, Flagship.sharedInstance.envId ?? "", visitorId)) else {
            /// The Url creation failed
            print("No Score found for this vsitor - in server API")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: getScoreUrl) { data, response, _ in
            if let response {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        print("Empty Content - Status Code:\(httpResponse.statusCode)")
                        completion(nil)
                    } else if httpResponse.statusCode == 200 {
                        do {
                            if let aData = data {
                                let scoreObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]
                                if let segmentDico = scoreObject["eai"] as? [String: String] {
                                    if let score = segmentDico["eas"] {
                                        print(" @@@@@@@@@@@@@ Your current score is: \(score ?? "NO score found in remote API") @@@@@@@@@@@@@@@@@@@@")
                                        completion(score)
                                        return
                                    }
                                }
                            }
                            print("No Score found for this vsitor - in server API")
                            completion(nil)
                        } catch {
                            print("Errro on fetching score: \(error.localizedDescription)")
                            completion(nil)
                        }

                    } else {
                        // Unknown error
                        print("Unknown error: \(httpResponse.statusCode)")
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    // Save the score locally
    private class func getSocreFromLocal() -> String? {
        UserDefaults.standard.string(forKey: FSEmmotionAIScoreKey)
    }

    private class func setSocreFromLocal(score: String) {
        UserDefaults.standard.set(score, forKey: FSEmmotionAIScoreKey)
    }
}
