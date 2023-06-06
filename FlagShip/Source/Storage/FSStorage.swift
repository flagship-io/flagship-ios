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
//    fileprivate init() {}
//
//    enum Directory {
//        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
//        case documents
//
//        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
//        case caches
//    }
//
//    /// Returns URL constructed from specified directory
//    fileprivate static func getURL(for directory: Directory) -> URL {
//        var searchPathDirectory: FileManager.SearchPathDirectory
//
//        switch directory {
//        case .documents:
//            searchPathDirectory = .documentDirectory
//        case .caches:
//            searchPathDirectory = .cachesDirectory
//        }
//
//        if var url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
//            url.appendPathComponent("FlagShipCampaign/Allocation", isDirectory: true)
//            do {
//                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
//
//                return url
//
//            } catch {
//                fatalError("Could not create URL for specified directory!")
//            }
//
//        } else {
//            fatalError("Could not create URL for specified directory!")
//        }
//    }
}
