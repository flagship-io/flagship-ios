//
//  Flagship+Config.swift
//  FlagshipTests
//
//  Created by Adel on 23/07/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation

@objc public enum FlagshipMode: NSInteger {

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

    public func setVisitorId(_ visitorId: String) {

        /// Manage visitor id
        do {
            self.visitorId =  try FSTools.manageVisitorId(visitorId)
            self.service?.visitorId = self.visitorId

        } catch {

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
    internal func onStartBucketing(_ onStartDone:@escaping(FlagshipResult) -> Void) {

        self.service?.getFSScript { (scriptBucket, error) in

            let bucketMgr: FSBucketManager = FSBucketManager()
            
            var aCampaigns:FSCampaigns?

            /// Error occured when trying to get script
            if error != nil {

                /// Read from cache the bucket script
                guard let cachedBucket: FSBucket =  self.service?.cacheManager.readBucketFromCache() else {

                    // Exit the start with not ready state
                    FSLogger.FSlog("No cached script available", .Campaign)
                    onStartDone(.NotReady)

                    return
                }

                /// Bucket the variations with the cached script
                aCampaigns = bucketMgr.bucketVariations(self.visitorId ?? "", cachedBucket)
            } else {
                /// Bucket the variation with a new script from server
                aCampaigns = bucketMgr.bucketVariations(self.visitorId ?? "", scriptBucket ?? FSBucket())
            }
            /// Check the panic mode before return
            self.checkPanicMode(newFlags:aCampaigns, onStartDone)
        }
    }

    ////////////////////////////////////////////////
    ///
    /// Get Decison Api on start the SDK
    ///
    /////////////////////////////////////////////
    internal func onStartDecisionApi(_ onStartDone:@escaping(FlagshipResult) -> Void) {

        // On starting make available the campaign already present in cache
        self.campaigns =  self.service?.cacheManager.readCampaignFromCache()
        /// update the modifications
        self.context.updateModification(self.campaigns)

        // Get campaign from server
        self.service?.getCampaigns(context.currentContext) { (aCampaigns, error) in

            if error == nil {
                /// Check the panic mode before return
                self.checkPanicMode(newFlags: aCampaigns,  onStartDone)
            } else {
                onStartDone(FlagshipResult.NotReady)
            }
        }
    }
    
    
    internal func checkPanicMode(newFlags:FSCampaigns?,_ onStartDone:@escaping(FlagshipResult) -> Void){
        
        // Check if the panic mode is activated
        if newFlags?.panic ?? false {

            // Update the state
            self.disabledSdk = true
            FSLogger.FSlog(String(format: "The SDK Flagship disabled from the flagship account - panic mode"), .Campaign)

            FSLogger.FSlog(String(format: "Default values will be returned by the getModification function"), .Campaign)
            
            onStartDone(FlagshipResult.Disabled)

        } else {
            self.disabledSdk = false
            self.campaigns = newFlags
            self.context.updateModification(newFlags)
            
            // update the state
            if consent {
                /// Send the keys/values context
                DispatchQueue(label: "flagship.contextKey.queue").async {

                    self.service?.sendkeyValueContext(self.context.currentContext)
                }
            }else{
                self.service?.sendHitConsent(_hasConsented: consent)
            }
            onStartDone(FlagshipResult.Ready)
        }
    }
}
