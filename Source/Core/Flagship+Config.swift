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
        
        /// Clear Context
        self.context.cleanContext()
        
        /// Clear Modifications
        self.context.cleanModification()
        
        /// Releoad the prédefined target
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }

    }
    
    
    
    /**
    Start FlagShip
       
    @param environmentId String environmentId id for client
     
    @param apiKey String
       
    @param visitorId String visitor id
     
    @param mode FlagshipMode, Start Flagship SDK in BUCKETING mode (client-side) or in DECISION_API mode (server-side)
     
    @param apacRegion apiKey string provided by ABTasty (See the documentation)
       
    @param completionHandler The block to be invoked when sdk is ready
    */
    internal func start(environmentId:String, apiKey:String, visitorId:String?, mode:FlagshipMode, onStartDone:@escaping(FlagshipResult)->Void){
        
        // Checkc the environmentId
        if (FSTools.chekcXidEnvironment(environmentId)){
            
            self.environmentId = environmentId
            
        }else{
            
            onStartDone(.NotReady)
            return
        }
        
        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            
        }catch{
            
            onStartDone(.NotReady)
            FSLogger.FSlog(String(format: "The visitor id is empty. The SDK Flagship is not ready "), .Campaign)
            return
        }
 
        // Get All Campaign for the moment
        self.service = ABService(self.environmentId, self.visitorId ?? "", apiKey)
        
               
        // Set the préconfigured Context
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }

        
        // Add the keys all_users temporary
        self.context.currentContext.updateValue("", forKey:ALL_USERS)

        
        // The current context is
        FSLogger.FSlog("The current context is : \(self.context.currentContext.description)", .Campaign)
        
        sdkModeRunning = mode
        
        switch sdkModeRunning {
            
        case .BUCKETING:
            onSatrtBucketing(onStartDone)
            break
            
        case .DECISION_API:
            onStartDecisionApi(onStartDone)
            break
        }
        
        
        
        /// Send the keys/values context
        DispatchQueue(label: "flagship.contextKey.queue").async {
            
            self.service?.sendkeyValueContext(self.context.currentContext)
        }
        
         // Purge data event
         DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
            self.service?.threadSafeOffline.flushStoredEvents()
         })
     }
    
    
    
     
    ////////////////////////////////////////////////
    ///
    /// Get Script on start the SDK
    ///
    /////////////////////////////////////////////
    internal func onSatrtBucketing(_ onStartDone:@escaping(FlagshipResult)->Void){
        
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
                self.campaigns = bucketMgr.bucketVariations(self.visitorId, cachedBucket)
            }else{
                /// Bucket the variation with a new script from server
                self.campaigns = bucketMgr.bucketVariations(self.visitorId, scriptBucket ?? FSBucket())
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
        
        // On starting make available the cache campaigns
        self.campaigns =  self.service?.cacheManager.readCampaignFromCache()
        self.context.updateModification(self.campaigns)

         // Update campaigns
        self.service?.getCampaigns(context.currentContext) { (campaigns, error) in

             if (error == nil){
                 // Set Campaigns

                 // Check if the panic button is activated
                 if (campaigns?.panic ?? false){

                     // Update the state
                     self.disabledSdk = true
                     FSLogger.FSlog(String(format: "The Flagship is disabled from the front"), .Campaign)

                     FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)

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
