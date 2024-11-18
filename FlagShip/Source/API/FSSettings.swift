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
        if let score = getSocreFromLocal() {
            completion(score)
        } else {
            // Replace the url later
            let url = URL(string: "https://my.api.mockaroo.com/score.json?key=d67200a0")!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                do {
                    if let aData = data {
                        let scoreObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]
                        let score = scoreObject["eas"] as? String

                        print(" @@@@@@@@@@@@@ Your current score is: \(score ?? "NO score found in remote API") @@@@@@@@@@@@@@@@@@@@")

                        // Set score to local
                        if let aScore = score {
                            // Uncomment later
                            // FSSettings.setSocreFromLocal(score: aScore)
                        }
                        completion(score)
                    }
                } catch {
                    print("Errro on fetching score: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    }

    // Save the score locally
    private class func getSocreFromLocal() -> String? {
         
        UserDefaults.standard.string(forKey: FSEmmotionAIScoreKey)
    }

    private class func setSocreFromLocal(score: String) {
        UserDefaults.standard.set(score, forKey: FSEmmotionAIScoreKey)
    }
}
