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
    
    var urlForEvent:URL?
    
    // Reachability
    let reachable:Reachability!
    
    init(_ service:ABService){
        
        self.service = service
        
        self.reachable = Reachability(hostname: "https://decision-api.canarybay.io")
        
        // Create directory to save the events
        self.urlForEvent = self.createUrlEventURL()
    }
    
    
    
    
    
    /// FLush Stored Event
    func flushStoredEvents(){
        
        // Flush All Events
        print("@@@@@@@@@@@@@ Flush all Events........................")
        self.getAllBodyTrackFromDisk()
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
//        guard let url:URL? = getDocumentsURL()?.appendingPathComponent(fileName) else {
//
//            print("Failed to save ..........")
//            return
//        }
//        do {
//            let data = try JSONSerialization.data(withJSONObject:body as Any, options:.prettyPrinted)
//
//            try data.write(to: url!, options: [])
//        } catch {
//            fatalError(error.localizedDescription)
//        }
    }
    
    
    // Get All Body Track from Documents
    
    func getAllBodyTrackFromDisk() -> [Dictionary<String, Any>]? {
        
        do {
            let listElementUrl = try FileManager.default.contentsOfDirectory(at: self.urlForEvent!, includingPropertiesForKeys: [], options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            print(listElementUrl)
            
        }catch{
            
        }
    
        
        return nil
    }
    
    
    
}
