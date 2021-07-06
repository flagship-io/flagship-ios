//
//  FSFlagShip+Context.swift
//  FlagShip
//
//  Created by Adel on 08/08/2019.
//

import Foundation

extension Flagship {

    ///////////////////////////// Boolean /////////////////////////
    ///
    /// Set key/value boolean to context
    /// - Parameters:
    ///   - key: name for key
    ///   - boolean: type of value
    public func updateContext(_ key: String, _ boolean: Bool) {

        self.context.addBoolenCtx(key, boolean)
    }

    /////////////////// Double //////////////////////////////////
    /// Set Double to context
    /// - Parameters:
    ///   - key: name for key
    ///   - double: value
    public func updateContext(_ key: String, _ double: Double) {

        self.context.addDoubleCtx(key, double)
    }

    /////////////////////////// Text //////////////////////////////
    /// Set String
    /// - Parameters:
    ///   - key: name for key
    ///   - text: value
    public func updateContext(_ key: String, _ text: String) {

        self.context.addStringCtx(key, text)
    }

//    /////////////////////////// Float /////////////////////////////
//    /// set Float to context
//    /// - Parameters:
//    ///   - key: name for key
//    ///   - float: value
//    public func updateContext(_ key:String,  _ float:Float){
//        
//        self.context.addFloatCtx(key, float)
//    }
//    

    /////////////////////////// Integer /////////////////////////////
    /// Set Integer to context
    /// - Parameters:
    ///   - key: name for key
    ///   - integer: value
    public func updateContext(_ key: String, _ integer: Int) {

        self.context.addIntCtx(key, integer)
    }

    /////////////////////// Dictionary ///////////////////////////
    @objc public func updateContext(_ contextValues: [String: Any]) {

        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        FSLogger.FSlog("Update context", .Campaign)

        self.context.currentContext.merge(contextValues) { (_, new) in new }
    }

    /**
     Update Context with Pre defined keys
     
     @param configuredKey PresetContext Enum for pre defined keys
     
     */
    public func updateContext(configuredKey: PresetContext, value: Any) {

        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }

        /// Check the validity value
        if !configuredKey.chekcValidity(value) {

            FSLogger.FSlog(" Skip updating the context with pre configured key \(configuredKey) ..... the value is not valid", .Campaign)
        }

        FSLogger.FSlog(" Update context with pre configured key", .Campaign)

        self.context.currentContext.updateValue(value, forKey: configuredKey.rawValue)

    }

    ///// Update context without dictionary //////////////////////
    @objc public func synchronizeModifications(completion:@escaping((FlagshipResult) -> Void)) {

        if disabledSdk {
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            completion(.Disabled)
            return
        }
        if sdkModeRunning == .DECISION_API {

            self.getCampaigns { (error) in

                if error == .None {

                    completion(.Updated)

                } else {

                    completion(.NotReady)
                }
            }
        } else {

            /// Read from cache the bucket script
            guard let cachedBucket: FSBucket =  self.service?.cacheManager.readBucketFromCache() else {

                // Exit the start with not ready state
                FSLogger.FSlog("No cached script available", .Campaign)
                completion(.NotReady)
                return
            }
            /// If the visitor is not set before, then the matchTargetingForCustomID can't process
            if  visitorId == nil {

                FSLogger.FSlog("the sync bucketing can't process because the visitorId is not set", .Campaign)
                completion(.NotReady)
                return
            }
            let bucketMgr: FSBucketManager = FSBucketManager()
            let resultBucketCache = bucketMgr.matchTargetingForCustomID(cachedBucket, visitorId, false)

            self.campaigns = FSCampaigns(resultBucketCache)

            self.context.updateModification( self.campaigns)

            completion(.Updated)

        }

    }

    /// Get context for the visitor
    /// - Returns: Dictionary , an empty one if the context is empty
    @objc public func getVisitorContext() -> [String: Any] {

        return self.context.currentContext
    }

    // Get all modifications for the visitor
    /// - Returns: Dictionary , an empty one if the modification is empty
    @objc public func getAllModification() -> [String: Any] {

        return self.context.currentModification
    }
}
