//
//  FSOfflineTracking.swift
//  FlagShip
//
//  Created by Adel on 21/08/2019.
//

import Foundation
import Reachability



public class FSOfflineTracking{
    
    // Service
    let service:ABService
    
    // Url Where to store the event
    var urlForEvent:URL?
    
    // Reachability
    let reachable:Reachability!
    
    init(_ service:ABService){
        
        self.service = service
        
        self.reachable = Reachability(hostname:FlagShipEndPoint)
        
        // Create directory to save the events
        self.urlForEvent = self.createUrlEventURL()
    }
    
    
    
    
    
    /// FLush Stored Event
    func flushStoredEvents(){
        // Flush All Events
        print("@@@@@@@@@@@@@ Flush all Events........................")
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
        
        print("Save Event ............................")
        
        DispatchWorkItem {
             self.saveBodyTrackToDisk(event.bodyTrack, event.fileName)
        }.perform()
       
    }
    
    
    // Is Connexion Available
    func isConnexionAvailable()->Bool{
        
        switch Reachability(hostname: "https://decision-api.canarybay.io")?.connection {
        case .cellular?, .wifi?:
            return true
        default:
            return false
        }
    }
    
    
    
    //// Tools
    
    func createUrlEventURL()->URL?{
        
        if var url:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("ABTasty", isDirectory: true)
            
           // FileManager.default.fileExists(atPath: url.path) // check .here 
            
            // create directory
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return url
                
            }catch{
                
                fatalError(error.localizedDescription)
            }
            
        }else{
            
            print("ooops ............")
            return nil
        }
    }
    
    
    func saveBodyTrackToDisk(_ body:Dictionary<String, Any>, _ fileName:String) {
        
        if (urlForEvent != nil){
            
            guard let url:URL? = urlForEvent?.appendingPathComponent(fileName) else {
                
                print("Failed to save ..........")
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
                    print(" .................Stored Event Sent with success ..........")
                    // Delete the Event
                    onCompletion(nil)
                    break
                default:
                    print(" .................Error on Sending Stored Event ..........")
                    onCompletion(.StoredEventError)
                }
                }.resume()
        }catch{
            fatalError(error.localizedDescription)
        }
    }
}
