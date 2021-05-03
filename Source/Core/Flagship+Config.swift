//
//  Flagship+Config.swift
//  FlagshipTests
//
//  Created by Adel on 23/07/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation


@objc public enum FlagshipMode:NSInteger{
    
    /// SDK is running in DECISION_API MODE
    case DECISION_API = 1
    
    /// SDK is running in BUCKETING MODE
    case BUCKETING    = 2
}



extension Flagship {
    
    /// Set visitor id at runtime
    /// - Parameters:
    ///   - visitorId: new visitor id to set
    /// - Warning: The Sdk will clear all context and modifications
    
    
    public func setVisitorId(_ visitorId:String){
        
        
        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            self.service?.visitorId = self.visitorId
            
        }catch{
            
            FSLogger.FSlog(String(format: "Failed to set The visitor id because is empty"), .Campaign)
            return
        }
        
        /// Clear Context
        self.context.cleanContext()
        
        /// Clear Modifications
        self.context.cleanModification()
        
        /// Releoad the prédefined target
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }
        
    }
    
    
    ////////////////////////////////////////////////
    ///
    /// Get Script on start the SDK
    ///
    /////////////////////////////////////////////
    internal func onStartBucketing(_ onStartDone:@escaping(FlagshipResult)->Void){
        
        self.service?.getFSScript { (scriptBucket, error) in
            
            let bucketMgr:FSBucketManager = FSBucketManager()
            
            /// Error occured when trying to get script
            if(error != nil){
                
                /// Read from cache the bucket script
                guard let cachedBucket:FSBucket =  self.service?.cacheManager.readBucketFromCache() else{
                    
                    // Exit the start with not ready state
                    FSLogger.FSlog("No cached script available",.Campaign)
                    onStartDone(.NotReady)
                    return
                }
                
                /// Bucket the variations with the cached script
                self.campaigns = bucketMgr.bucketVariations(self.visitorId ?? "", cachedBucket)
            }else{
                /// Bucket the variation with a new script from server
                self.campaigns = bucketMgr.bucketVariations(self.visitorId ?? "", scriptBucket ?? FSBucket())
            }
            
            /// Update the modifications
            self.context.updateModification(self.campaigns)
            
            
            /// Call back with Ready state
            onStartDone(.Ready)
        }
    }
    
    
    ////////////////////////////////////////////////
    ///
    /// Get Decison Api on start the SDK
    ///
    /////////////////////////////////////////////
    internal func onStartDecisionApi(_ onStartDone:@escaping(FlagshipResult)->Void){
        
        // On starting make available the campaign already present in cache
        self.campaigns =  self.service?.cacheManager.readCampaignFromCache()
        self.context.updateModification(self.campaigns)
        
        // Get campaign from server
        self.service?.getCampaigns(context.currentContext) { (campaigns, error) in
            
            if (error == nil){
                
                // Check if the panic button is activated
                if (campaigns?.panic ?? false){
                    
                    // Update the state
                    self.disabledSdk = true
                    FSLogger.FSlog(String(format: "The SDK Flagship disabled from the flagship account - panic mode"), .Campaign)
                    
                    FSLogger.FSlog(String(format: "Default values will be returned by the getModification function"), .Campaign)
                    
                    onStartDone(FlagshipResult.Disabled)
                    
                }else{
                    
                    self.disabledSdk = false
                    self.campaigns = campaigns
                    self.context.updateModification(campaigns)
                    onStartDone(FlagshipResult.Ready)
                }
            }else{
                onStartDone(FlagshipResult.NotReady)
            }
        }
    }
    
    
    
}
