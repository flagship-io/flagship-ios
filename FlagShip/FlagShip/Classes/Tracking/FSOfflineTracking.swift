//
//  FSOfflineTracking.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation
//import Reachability
import SystemConfiguration
import Network


public class FSOfflineTracking{
    
    // Service
    let service:ABService
    
    // Url Where to store the event
    var urlForEvent:URL?
    
    // Reachability
   // let reachable:Reachability!
    
    init(_ service:ABService){
        
        self.service = service
        
       // self.reachable = Reachability(hostname:FlagShipEndPoint)
        
        // Create directory to save the events
        self.urlForEvent = self.createUrlEventURL()
    }
    
    
    
    
    
    /// FLush Stored Event
    func flushStoredEvents(){
        // Flush All Events
        FSLogger.FSlog("Flush all Events", .Campaign)
        let listUrl =  self.getAllBodyTrackFromDisk()
        
        for urlItem:URL in listUrl ?? []{
            self.sendSavedEventFromUrl(urlItem) { (error) in
                
                if (error == nil){
                    do{
                         try FileManager.default.removeItem(at: urlItem)
                    }catch{
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    
    // Save Events
    func saveEvent<T:FSTrackingProtocol>(_ event:T){
        
        FSLogger.FSlog("save event", .Campaign)
        
        DispatchWorkItem {
             self.saveBodyTrackToDisk(event.bodyTrack, event.fileName)
        }.perform()
    }
    
    func saveActivateEvent(_ dateEvent:Data){
        
        FSLogger.FSlog("save Activate Event", .Campaign)
        
        DispatchQueue(label: "save.activate.event").async {
            
            if (self.urlForEvent != nil){
                
                // Create file name
                let formatDate = DateFormatter()
                formatDate.dateFormat = "MMddyyyyHHmmssSSSS"
                let fileName =  String(format: "%@.json",formatDate.string(from: Date()))
                
                guard let url:URL? = self.urlForEvent?.appendingPathComponent(fileName) else {
                    
                    FSLogger.FSlog("Failed to save activate event", .Campaign)
                    
                    return
                }
                do {
                    try dateEvent.write(to: url!, options: [])
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    
    // Is Connexion Available
    func isConnexionAvailable()->Bool{
        
        let reachability = SCNetworkReachabilityCreateWithName(nil, "https://decision-api.canarybay.io")
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        return flags.contains(.reachable)
    }
    
    
    //// Tools
    func createUrlEventURL()->URL?{
        
        if var url:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("ABTasty", isDirectory: true)
            
            
            // create directory
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return url
                
            }catch{
                
                fatalError(error.localizedDescription)
            }
            
        }else{
            
            FSLogger.FSlog("Flush all Events", .Network)
            return nil
        }
    }
    
    
    func saveBodyTrackToDisk(_ body:Dictionary<String, Any>, _ fileName:String) {
        
        if (urlForEvent != nil){
            
            guard let url:URL? = urlForEvent?.appendingPathComponent(fileName) else {
                
                FSLogger.FSlog("Failed to save event", .Campaign)
                return
            }
            do {
                let data = try JSONSerialization.data(withJSONObject:body as Any, options:.prettyPrinted)
                
                try data.write(to: url!, options: [])
            } catch {
                fatalError(error.localizedDescription)
            }

        }
    }
    
    
    // Get All Body Track from Documents
    func getAllBodyTrackFromDisk() -> [URL]?{
        
        do {
            let listElementUrl = try FileManager.default.contentsOfDirectory(at: self.urlForEvent!, includingPropertiesForKeys: [.creationDateKey], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            return listElementUrl
            
        }catch{
            
            fatalError(error.localizedDescription)
        }
    }
    
    
    /// Send Event  From URL
    func sendSavedEventFromUrl(_ url:URL, onCompletion:@escaping(FlagshipError?)->Void){
        
        // Get data from URL
        do{
            let data = try Data(contentsOf: url)
            var request:URLRequest = URLRequest(url: URL(string:FSDATA_ARIANE)!)
            
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let session = URLSession(configuration:URLSessionConfiguration.default)
            
            session.dataTask(with: request) { (responseData, response, error) in
                
                let httpResponse = response as? HTTPURLResponse
                
                switch (httpResponse?.statusCode){
                    
                case 200:
                    FSLogger.FSlog(" .................Stored Event Sent with success ..........", .Network)
                    // Delete the Event
                    onCompletion(nil)
                    break
                default:
                    FSLogger.FSlog(" .................Error on Sending Stored Event ..........", .Network)
                    onCompletion(.StoredEventError)
                }
                }.resume()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
}
