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
    class func fetchRessources(completion: @escaping ([String: Any]) -> Void) {
        print("get ressources")
        let url = URL(string: "https://my.api.mockaroo.com/settings.json?key=d67200a0")!

        URLSession.shared.dataTask(with: url) { data, _, _ in

            do {
                if let aData = data {
                    let scriptObject = try JSONSerialization.jsonObject(with: aData, options: []) as! [String: Any]

                    completion(scriptObject)
                }

            } catch {
                print("zuuut error")

                completion([:])
            }

        }.resume()
    }
//
//    class func fetchScore(completion: @escaping (String) -> Void) {
//        if let score = getSocreFromLocal() {
//            completion(score)
//        }else {
//            
//            let url = URL(string: "https://my.api.mockaroo.com/score.json?key=d67200a0")!
//            
//            URLSession.shared.dataTask(with: url) { data, _, _ in
//                
//                do {
//                    if let aData = data {
//                        let scoreObject = try JSONSerialization.jsonObject(with: aData, options: [
//                            }
//                            }
//                            }
//        }
//    }
//
//    private class func getSocreFromLocal() -> String? {
//        UserDefaults.standard.string(forKey: FSEmmotionAIScoreKey)
//    }
}
