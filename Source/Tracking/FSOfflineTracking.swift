//
//  FSOfflineTracking.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation
import SystemConfiguration
import Network

internal class FSOfflineTracking {

    // Service
    let service: ABService

    // Url Where to store the event
    var urlForEvent: URL?

    init(_ service: ABService) {

        self.service = service

        // Create directory to save the events
        self.urlForEvent = self.createUrlEventURL()
    }

    /// FLush Stored Event
    func flushStoredEvents() {
        // Flush All Events
        FSLogger.FSlog("Flush all Events", .Campaign)
        let listUrl =  self.getAllBodyTrackFromDisk()

        for urlItem: URL in listUrl ?? [] {
            self.sendSavedEventFromUrl(urlItem) { (error) in

                if error == nil {
                    do {
                        try FileManager.default.removeItem(at: urlItem)
                    } catch {

                        FSLogger.FSlog("Failed to save event in cache", .Network)
                    }
                }
            }
        }
    }

    // Save Events
    func saveEvent<T: FSTrackingProtocol>(_ event: T) {

        FSLogger.FSlog("save event", .Campaign)

        DispatchWorkItem {

            // before save the body, save also the cst, will use it later on send

            var eventBodyToSave = event.bodyTrack

            eventBodyToSave.updateValue(event.getCst() ?? 0, forKey: "cst")

            self.saveBodyTrackToDisk(eventBodyToSave, event.fileName)

        }.perform()
    }

    func saveActivateEvent(_ dateEvent: Data) {

        FSLogger.FSlog("save Activate Event", .Campaign)

        DispatchQueue(label: "save.activate.event").async {

            if self.urlForEvent != nil {

                // Create file name
                let formatDate = DateFormatter()
                formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
                let fileName =  String(format: "%@.json", formatDate.string(from: Date()))

                guard let url: URL = self.urlForEvent?.appendingPathComponent(fileName) else {

                    FSLogger.FSlog("Failed to save activate event", .Campaign)

                    return
                }
                do {
                    try dateEvent.write(to: url, options: [])
                } catch {

                    FSLogger.FSlog("Failed to write event in cache", .Network)

                }
            }
        }
    }

    // Is Connexion Available
    func isConnexionAvailable() -> Bool {

        let reachability = SCNetworkReachabilityCreateWithName(nil, "https://decision-api.canarybay.io")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        return flags.contains(.reachable)
    }

    //// Tools
    func createUrlEventURL() -> URL? {

        if var url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("ABTasty", isDirectory: true)

            // create directory
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return url

            } catch {

                FSLogger.FSlog("Failed to create directory", .Network)
                return nil
            }

        } else {

            FSLogger.FSlog("Flush all Events", .Network)
            return nil
        }
    }

    func saveBodyTrackToDisk(_ body: [String: Any], _ fileName: String) {

        if urlForEvent != nil {

            guard let url: URL = urlForEvent?.appendingPathComponent(fileName) else {

                FSLogger.FSlog("Failed to save event", .Campaign)
                return
            }
            do {

                let data = try JSONSerialization.data(withJSONObject: body as Any, options: .prettyPrinted)

                try data.write(to: url, options: [])
            } catch {

                FSLogger.FSlog("Failed to write track infos", .Parsing)
            }

        }
    }

    // Get All Body Track from Documents
    func getAllBodyTrackFromDisk() -> [URL]? {

        if let urlEvent = self.urlForEvent {

            do {
                let listElementUrl = try FileManager.default.contentsOfDirectory(at: urlEvent, includingPropertiesForKeys: [.creationDateKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)

                return listElementUrl

            } catch {

                FSLogger.FSlog("Failed to read info track from directory", .Network)
                return nil
            }
        }
        return nil
    }

    /// Send Event  From URL
    func sendSavedEventFromUrl(_ url: URL, onCompletion:@escaping(FlagshipError?) -> Void) {

        do {
            let data = try Data(contentsOf: url)

            // make sure this JSON is in the format we expect
            if var savedInfoEventJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                /// Get cst time stored
                if let savedCst = savedInfoEventJson["cst"] as? NSNumber {

                    /// Calculate QueueTime
                    let qt: Double = Date.timeIntervalSinceReferenceDate - savedCst.doubleValue
                    /// Set QueueTime
                    savedInfoEventJson.updateValue(qt, forKey: "qt")
                    /// Remove cst Time
                    savedInfoEventJson.removeValue(forKey: "cst")

                }

                /// Convert to data
                let newData = try JSONSerialization.data(withJSONObject: savedInfoEventJson as Any, options: .prettyPrinted)

                if let urlSendEvent =  URL(string: FSDATA_ARIANE) {

                    var request: URLRequest = URLRequest(url: urlSendEvent)
                    request.httpMethod = "POST"
                    request.httpBody = newData
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

                    let session = URLSession(configuration: URLSessionConfiguration.default)

                    session.dataTask(with: request) { (_, response, _) in

                        let httpResponse = response as? HTTPURLResponse

                        switch httpResponse?.statusCode {

                        case 200:
                            FSLogger.FSlog(" .................Stored Event Sent with success ..........\n\n \(savedInfoEventJson) \n\n ", .Network)
                            // Delete the Event
                            onCompletion(nil)
                            break
                        default:
                            FSLogger.FSlog(" .................Error on Sending Stored Event ..........", .Network)
                            onCompletion(.StoredEventError)
                        }
                    }.resume()
                }
            }
        } catch {

            FSLogger.FSlog("Failed to send Event", .Network)

        }
    }
}
