//
//  FSStorage.swift
//  FlagShip-framework
//
//  Created by Adel on 03/12/2019. From Saoud M. Rizwan
//  https://medium.com/@sdrzn/swift-4-codable-lets-make-things-even-easier-c793b6cf29e1
//

import Foundation

import Foundation
/// :nodoc:
public class FSStorage {

    fileprivate init() { }

    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents

        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }

    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }

        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            
            url.appendPathComponent("FlagShipCampaign/Allocation", isDirectory: true)
            do {
                
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes:nil)
                
                return url

            }catch{
                
                fatalError("Could not create URL for specified directory!")
            }
            
        } else {

            fatalError("Could not create URL for specified directory!")
        }
    }
    
    
    /// Store Data struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - dataToStore: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store(_ dataToStore: Data, to directory: Directory, as fileName: String) {
      
        /// create the url
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        /// create file
        FileManager.default.createFile(atPath: url.path, contents: dataToStore, attributes: nil)
    }
    
    /// Retrieve Data from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    /// - Returns: decoded struct model(s) of data
    static func retrieve(_ fileName: String, from directory: Directory) -> Data? {
        
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        if !FileManager.default.fileExists(atPath: url.path) {
            
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("File at path \(url.path) does not exist!"))
            return nil
        }
        return FileManager.default.contents(atPath: url.path)
    }
    
    

    /// Store an encodable struct to the specified directory on disk
    ///
    /// - Parameters:
    ///   - object: the encodable struct to store
    ///   - directory: where to store the struct
    ///   - fileName: what to name the file where the struct data will be stored
    static func store<T: Encodable>(_ object: T, to directory: Directory, as fileName: String) {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {

                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {

            FlagshipLogManager.Log(level: .ALL, tag: .EXCEPTION, messageToDisplay:FSLogMessage.ERROR_ON_STORE)
        }
    }

    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - fileName: name of the file where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)

        if !FileManager.default.fileExists(atPath: url.path) {
            
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("File at path \(url.path) does not exist!"))
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE(error.localizedDescription))
                return nil
            }
        } else {
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("No data at \(url.path)!"))
            return nil
        }
    }

    /// Returns BOOL indicating whether file exists at specified directory with specified file name
    static func fileExists(_ fileName: String, in directory: Directory) -> Bool {
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    internal static func deleteSavedAllocations(){
        do{
            try FileManager.default.removeItem(at: getURL(for: .documents))
            
            FlagshipLogManager.Log(level: .ALL, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("Delete all saved allocation"))
        }catch{
            FlagshipLogManager.Log(level: .ALL, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Failed to delete saved allocation"))
        }
    }
    
    /// Delete the cached file
    internal static func deleteFile(_ fileName:String, from directory: Directory){
        
        let url = getURL(for: directory).appendingPathComponent(fileName, isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("The cache visitor don't exist or already deleted"))
            return 
        }
        do{
            try FileManager.default.removeItem(at: url)
            FlagshipLogManager.Log(level: .DEBUG, tag: .STORAGE, messageToDisplay:FSLogMessage.MESSAGE("The cache visitor was deleted"))
        }catch{
            FlagshipLogManager.Log(level: .ERROR, tag: .EXCEPTION, messageToDisplay:FSLogMessage.MESSAGE("Error on delete file \(fileName)"))
        }
    }
    
    
    /// Retrieve and convert a struct from a file on disk
    ///
    /// - Parameters:
    ///   - url: url where struct data is stored
    ///   - directory: directory where struct data is stored
    ///   - type: struct type (i.e. Message.self)
    /// - Returns: decoded struct model(s) of data
    static func retrieve<T: Decodable>(_ url: URL, from directory: Directory, as type: T.Type) -> T? {
        
        if !FileManager.default.fileExists(atPath: url.path) {
            
            FlagshipLogManager.Log(level: .ALL, tag:.STORAGE, messageToDisplay:FSLogMessage.ERROR_lOOKUP_CACHE)
            return nil
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                let model = try decoder.decode(type, from: data)
                return model
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    /// Retrieve Data from a url in disk
    ///
    /// - Parameters:
    ///   - url: url where struct data is stored
    ///   - directory: directory where struct data is stored
    /// - Returns: Data?
    static func retrieve(_ url: URL, from directory: Directory) -> Data? {
        
        if !FileManager.default.fileExists(atPath: url.path) {
            
            FlagshipLogManager.Log(level: .ALL, tag:.STORAGE, messageToDisplay:FSLogMessage.ERROR_lOOKUP_CACHE)
            return nil
        }
        return FileManager.default.contents(atPath: url.path)
    }
}
