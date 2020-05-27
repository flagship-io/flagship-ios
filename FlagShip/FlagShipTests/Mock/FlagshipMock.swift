//
//  FlagshipMock.swift
//  FlagshipTests
//
//  Created by Adel on 27/05/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit

@testable import Flagship

class FlagshipMock:Flagship {
    
    
    override init() {
        
        super.init()
//        self.context = FSContext()
//        
//        self.audience = FSAudience()
    }
    
    
    
    

     internal func startMock(environmentId:String, _ visitorId:String?, _ mode:FlagshipMode, apacRegion:FSRegion? = nil, completionHandler:@escaping(FlagshipResult)->Void){
        
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
 
        self.service = ServiceMock(self.environmentId, self.visitorId ?? "", region: apacRegion)

        
               
         // Set the préconfigured Context
        self.context.currentContext.merge(FSPresetContext.getPresetContextForApp()) { (_, new) in new }

        
        // Add the keys all_users temporary
        self.context.currentContext.updateValue("", forKey:ALL_USERS)

        
        // The current context is
        FSLogger.FSlog("The current context is : \(self.context.currentContext.description)", .Campaign)
        
        // set mode running
        self.sdkModeRunning = mode
        
        
        switch self.sdkModeRunning {
        case .BUCKETING:
            
            self.service?.getFSScript { (scriptBucket, error) in
                
                let bucketMgr:FSBucketManager = FSBucketManager()
                
                /// Error occured when trying to get script
                if(error != nil){
                
                    /// Read from cache the bucket script
                    guard let cachedBucket:FSBucket =  self.service?.cacheManager.readBucketFromCache() else{
                        
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
            self.campaigns =  self.service?.cacheManager.readCampaignFromCache()
             self.context.updateModification(self.campaigns)
             
             // Mettre à jour les campaigns
            self.service?.getCampaigns(context.currentContext) { (campaigns, error) in
                 
                 if (error == nil){
                     // Set Campaigns
                     
                     // Check if the panic button is activated
                     if (campaigns?.panic ?? false){
                         
                         // Update the state
                         self.disabledSdk = true
                         FSLogger.FSlog(String(format: "The Flagship is disabled from the front"), .Campaign)
                         
                         FSLogger.FSlog(String(format: "Default values will be set by the SDK"), .Campaign)

                         completionHandler(FlagshipResult.Disabled)
                         
                     }else{
                         
                         self.disabledSdk = false
                         self.campaigns = campaigns
                         self.context.updateModification(campaigns)
                         completionHandler(FlagshipResult.Ready)
                     }
                 }else{
                     completionHandler(FlagshipResult.NotReady)
                 }
             }
            break
        }
         // Purge data event
         DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute:DispatchWorkItem {
            self.service?.offLineTracking.flushStoredEvents()
         })
     }
    

}
