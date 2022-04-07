//
//  FSCacheDelegate.swift
//  Flagship
//
//  Created by Adel on 28/12/2021.
//


import Foundation


 @objc public protocol FSVisitorCacheDelegate:AnyObject {
     
     
     /// Called after each synchronization. Must upsert the given visitor json data in the database.
     func cacheVisitor(visitorId:String, _ visitorData: Data)
    
    /// Called right at visitor creation
    func lookupVisitor(visitorId:String)->Data? //json data
    
    /// Called when a visitor set consent to false. Must erase visitor data related to the given visitor
    /// Id from the database.
    func flushVisitor(visitorId:String)
}



@objc public protocol FSHitCacheDelegate:AnyObject{
    
    func cacheHit(visitorId:String, data:Data)
    
    /// Lookup
  //  func lookupHits(visitorId:String)->[FSCacheHit]?
    
    /// Lookup
    func lookupHits(visitorId:String)->[Data]?
    
    
    /// Flush all hit
    func flushHits(visitorId:String)
    
    


}
