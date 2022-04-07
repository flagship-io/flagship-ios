//
//  FSVisitor+Campaigns.swift
//  Flagship
//
//  Created by Adel on 01/10/2021.
//

import Foundation

extension FSVisitor{
    
    
    internal func updateFlags(_ newFlags:[String:FSModification]?){
        
        if let aNewFlag = newFlags{
            /// Clean the current flag
            currentFlags.removeAll()
            currentFlags = aNewFlag
        }
    }
    
    internal func mergeCachedVisitor(_ cachedVisitor:FSCacheVisitor){
        
        /// Retreive cached flags and Merge in the visitor instance
        var cachedFlgs:[String:FSModification] = [:]
        for item in cachedVisitor.data?.campaigns ?? []{
            
            cachedFlgs.merge(item.getFlagsFromCachedCampaign()){  (_, new) in new }
        }
        /// Merge with current Flags for visitor instance
        if (!cachedFlgs.isEmpty){
            self.currentFlags.merge(cachedFlgs){(_,new)in new}
        }
        /// Retreive the context and Merge it
        if let cachedContext = cachedVisitor.data?.context{
            
            self.context.mergeContext(cachedContext) /// To do later
        }
    }
    
    
    /// _ Get relative information about the activation
    /// if the key don't exist then will return nil
    internal func getActivateInformation(_ key:String)-> [String:Any]?{
        
        if let aModification = self.currentFlags[key]{
            
            var infosTrack = ["vaid": aModification.variationId, "caid": aModification.variationGroupId,"vid":self.visitorId ]
            
            if let aId = self.anonymousId{
                
                infosTrack.updateValue(aId, forKey: "aid")
            }
            if let aEnvId = Flagship.sharedInstance.envId {
                
                infosTrack.updateValue(aEnvId, forKey: "cid")
            }
            return infosTrack
        }
        return nil
    }
}
