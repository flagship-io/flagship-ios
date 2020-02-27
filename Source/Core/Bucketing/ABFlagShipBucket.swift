//
//  ABFlagShipBucket.swift
//  FlagShip-framework
//
//  Created by Adel on 19/11/2019.
//

import UIKit




@objc public enum FlagShipMode:NSInteger{
    
    case DECISION_API = 1
    case BUCKETING    = 2
}



 extension Flagship {
    
    
    /// Use service for bucket Flagship
    
     @objc public  func startFlagShipWithMode(environmentId:String, _ visitorId:String?,_ mode:FlagShipMode, completionHandler:@escaping(FlagShipResult)->Void){
        
        // Checkc the environmentId
        if (FSTools.chekcXidEnvironment(environmentId)){
            
            self.environmentId = environmentId
            
        }else{
            
            completionHandler(.NotReady)
            return
        }
        
        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            
        }catch{
            
            completionHandler(.NotReady)
            FSLogger.FSlog(String(format: "The visitor id is empty. The SDK Flagship is not ready "), .Campaign)
            return
        }
        
         
         // Create tuple
         fsProfile = FSProfile(self.visitorId)
         
         // Get All Campaign for the moment
        self.service = ABService(self.environmentId, self.visitorId ?? "")
        
        // Set the préconfigured audience
        self.context.currentContext.merge(FSAudience.getAudienceForApp()) { (_, new) in new }
        
        // Add the keys all_users temporary
        self.context.currentContext.updateValue("", forKey:ALL_USERS)

        
        // The current context is
        FSLogger.FSlog("The current context is : \(self.context.currentContext.description)", .Campaign)
        
        // set mode running
        self.sdkModeRunning = mode
        
        
        switch self.sdkModeRunning {
        case .BUCKETING:
            
            self.service.getFSScript { (scriptBucket, error) in
                
                let bucketMgr:FSBucketManager = FSBucketManager()
                
                /// Error occured when trying to get script
                if(error != nil){
                
                    /// Read from cache the bucket script
                    guard let cachedBucket:FSBucket =  self.service.cacheManager.readBucketFromCache() else{
                        
                        // Exit the start with not ready state
                        FSLogger.FSlog("No cached script available",.Campaign)
                        completionHandler(.NotReady)
                        return
                    }
                    
                    /// Bucket the variations with the cached script
                    self.campaigns = bucketMgr.bucketVariations(self.fsProfile.visitorId, cachedBucket)
                }else{
                    /// Bucket the variation with a new script from server
                    self.campaigns = bucketMgr.bucketVariations(self.fsProfile.visitorId, scriptBucket ?? FSBucket())
                }
                /// Update the modifications
                self.context.updateModification(self.campaigns)
                /// Call back with Ready state
                completionHandler(.Ready)
            }
            
            break
        case .DECISION_API:
            
            // Au départ mettre a dispo les campaigns du cache.
             self.campaigns =  self.service.cacheManager.readCampaignFromCache()
             self.context.updateModification(self.campaigns)
             
             // Mettre à jour les campaigns
             self.service.getCampaigns(context.currentContext) { (campaigns, error) in
                 
                 if (error == nil){
                     // Set Campaigns
                     
                     // Check if the panic button is activated
                     if (campaigns?.panic ?? false){
                         
                         // Update the state
                         self.disabledSdk = true
                         FSLogger.FSlog(String(format: "The Flagship is disabled from the front"), .Campaign)
                         
                         FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)

                         completionHandler(FlagShipResult.Disabled)
                         
                     }else{
                         
                         self.disabledSdk = false
                         self.campaigns = campaigns
                         self.context.updateModification(campaigns)
                         completionHandler(FlagShipResult.Ready)
                     }
                 }else{
                     completionHandler(FlagShipResult.NotReady)
                 }
             }
            break
        }
         // Purge data event
         DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
             self.service.offLineTracking.flushStoredEvents()
         })
     }
    
    
    
    /// Set User id at runtime
    /// - Parameters:
    ///   - visitorId: new visitor id to set
    ///   - clearModifications: optional, by default true to clear all modifications values
    ///   - clearContextValues: optional, by default true to clear all context values
    /// - Warning: Once all modifications are removed, the SDK will return a default value, you may need to update the FLagship with new context relative to the visitor id to in order to get a new modification
    
    
    public func setVisitorId(_ visitorId:String){
        
        /// Clear Context
        self.context.cleanContext()
        
        /// Clear Modifications
        self.context.cleanModification()
        
        /// Releoad the prédefined target
        self.context.currentContext.merge(FSAudience.getAudienceForApp()) { (_, new) in new }
    }
}

