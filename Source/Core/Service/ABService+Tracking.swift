//
//  ABService+Tracking.swift
//  FlagShip
//
//  Created by Adel on 12/08/2019.
//

import Foundation

internal extension ABService {

    func sendTracking< T: FSTrackingProtocol>(_ event: T) {

        self.sendEvent(event)
    }
    
    
    // Send Hit consent
    func sendHitConsent(_hasConsented :Bool){
        // create the hit consent
        let consentHit = FSConsent(eventCategory: .User_Engagement, eventAction:FSConsentAction)
        consentHit.label =  String(format:"iOS:%@",_hasConsented ? "true":"false")
        sendEvent(consentHit)
    }

    ////////////////////: Send Event ...///////////////////////////////////////////////:

    func sendEvent< T: FSTrackingProtocol>(_ event: T) {

        /// Check if the connexion is available

        if self.threadSafeOffline.isConnexionAvailable() == false {

            FSLogger.FSlog("The connexion is not available ..... The event will be saved in Data Base", .Network)

            self.threadSafeOffline.saveEvent(event)

            return
        }

        do {

            FSLogger.FSlog(String(format: "\n\n\n Sending Event : ....... %@ \n\n\n", event.bodyTrack.debugDescription), .Network)

            let data = try JSONSerialization.data(withJSONObject: event.bodyTrack as Any, options: .prettyPrinted)

            if let urlEvent = URL(string: FSDATA_ARIANE) {

                var request: URLRequest = URLRequest(url: urlEvent)
                request.httpMethod = "POST"
                request.httpBody = data
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                let session = URLSession(configuration: URLSessionConfiguration.default)

                session.dataTask(with: request) { (_, response, _) in

                    let httpResponse = response as? HTTPURLResponse

                    switch httpResponse?.statusCode {

                    case 200, 201:
                        FSLogger.FSlog("Event sent with success \n\n \(event.bodyTrack) \n\n", .Network)
                        break

                    default:
                        FSLogger.FSlog("Error on send Event", .Network)
                    }

                }.resume()
            }

        } catch {

            FSLogger.FSlog("Error serialize  event ", .Network)
        }

    }
}
