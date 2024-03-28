//
//  FSBucketingManager.swift
//  Flagship
//
//  Created by Adel on 26/10/2021.
//

import Foundation

let SemaphoreTimeOut: TimeInterval = 2

class FSBucketingManager: FSDecisionManager, FSPollingScriptDelegate {
   // var pollingScript: FSPollingScript?
    var _scriptBucket: FSBucket?
    var _scriptError: FlagshipError?
    var targetManager: FSTargetingManager
    var matchedVariationGroup: [FSVariationGroup] = [] // Init with empty array
    var matchedCampaigns: [FSCampaignCache] = []
    let fsQueue = DispatchQueue(label: "com.flagship.queue", attributes: .concurrent)

    var scriptBucket: FSBucket? {
        get {
            return fsQueue.sync {
                _scriptBucket
            }
        }
        set {
            fsQueue.async(flags: .barrier) {
                self._scriptBucket = newValue
            }
        }
    }

    var scriptError: FlagshipError? {
        get {
            return fsQueue.sync {
                _scriptError
            }
        }
        set {
            fsQueue.async(flags: .barrier) {
                self._scriptError = newValue
            }
        }
    }

    // init Manager
    init(service: FSService, userId: String, currentContext: [String: Any], _ pollingTime: TimeInterval) {
        self.targetManager = FSTargetingManager()

        super.init(service: service, userId: userId, currentContext: currentContext)
        
        /// Get the initial stored script ... before the to start listen 
        if let storedBucket = FSStorageManager.readBucketFromCache() {
            self.scriptBucket = storedBucket
        }
 
        /// Add observer to listen "onGetScriptNotification"
        NotificationCenter.default.addObserver(self, selector: #selector(onGetNotification), name: NSNotification.Name(FSBucketingScriptNotification), object: nil)
    }

    override func getCampaigns(_ currentContext: [String: Any], withConsent: Bool, _ pAssignationHistory: [String: String] = [:], completion: @escaping (FSCampaigns?, Error?) -> Void) {
        assignationHistory = pAssignationHistory
        DispatchQueue.main.async {
            // Set the context before running the bucket algorithm
            self.targetManager.currentContext = currentContext
            self.targetManager.userId = self.userId

            if let aScriptBucket = self.scriptBucket {
                let aCampaigns = self.bucketVariations(self.userId, aScriptBucket)
                completion(aCampaigns, self.scriptError)
            } else {
                completion(nil, self.scriptError)
            }
        }
    }

    /// Launch polling
    override func launchPolling() {
        //pollingScript?.launchPolling()
    }

    /// Delegate -- The polling process will trigger this callback
    func onGetScript(_ newBucketing: FSBucket?, _ error: FlagshipError?) {
        /// Update the status

        if let aNewBuckting = newBucketing {
            // Refonte status
            Flagship.sharedInstance.updateStatus(aNewBuckting.panic ? .SDK_NOT_INITIALIZED : .SDK_INITIALIZED)
 
        }
        /// Update bucketing
        scriptBucket = newBucketing
        /// Update script error
        scriptError = error
    }

    @objc private func onGetNotification(_ notification: Notification) {
        // Get the object
        if let aScriptBucket = notification.object as? FSBucket {
            Flagship.sharedInstance.updateStatus(aScriptBucket.panic ? .SDK_PANIC : .SDK_INITIALIZED)
            
            /// Update bucketing
            scriptBucket = aScriptBucket
        }
    }

    /// This is the entry for bucketing , that give the campaign infos as we do in api decesion
    func bucketVariations(_ visitorId: String, _ scriptBucket: FSBucket) -> FSCampaigns? {
        /// Check the panic mode

        if scriptBucket.panic == true {
            return FSCampaigns(visitorId, panic: true)
        }

        // check if the user exist in the cache , if yes then read his own modification from the cache

        // If not extract the variations

        // check the targetings and filter the variation he can run

        // Match before
        let resultBucketCache = matchTargetingForCustomID(scriptBucket, visitorId)

        // Set Extras information
        resultBucketCache.extras = FSExtras(scriptBucket.accountSettings)

        // Fill Campaign with value to be read by singleton
        return FSCampaigns(resultBucketCache)
    }

    /// Extract the variations where the user is allowed to seee

    func matchTargetingForCustomID(_ scriptBucket: FSBucket?, _ visitorId: String) -> FSBucketCache {
        let fsCampaignBucketCache = FSBucketCache(visitorId)

        matchedVariationGroup.removeAll()

        var groupCampaigns: [FSCampaignCache] = []
        var groupVar: [FSVariationGroupCache] = []

        groupCampaigns.removeAll()

        if let campaignsArray = scriptBucket?.campaigns {
            for bucketCampaignItem: FSBucketCampaign in campaignsArray {
                groupVar.removeAll()

                for variationGroupItem: FSVariationGroup in bucketCampaignItem.variationGroups {
                    if targetManager.isTargetingGroupIsOkay(variationGroupItem.targeting) {
                        FlagshipLogManager.Log(level: .ALL, tag: .ALLOCATION, messageToDisplay: FSLogMessage.MESSAGE("Target for \(variationGroupItem.idVariationGroup) is OKAY ✅ "))

                        // select variation here
                        guard let variationIdSelected = selectVariationWithHashMurMur(visitorId, variationGroupItem) else {
                            // FSLogger.FSlog("probleme here don 't found the id variation selected", .Campaign)

                            FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.MESSAGE("Problem here don 't found the id variation selected"))
                            continue
                        }

                        // Get all modification according to id variation

                        let variationCache: FSVariationCache = .init(variationIdSelected)

                        for itemVariation in variationGroupItem.variations {
                            if itemVariation.idVariation == variationIdSelected {
                                // the variationIdSelected is found , populate the attributes
                                variationCache.modification = itemVariation.modifications
                                variationCache.reference = itemVariation.reference
                                variationCache.variationName = itemVariation.name
                            }
                        }

                        groupVar.append(FSVariationGroupCache(variationGroupItem.idVariationGroup, variationGroupItem.name, variationCache))

                    } else {
                        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: FSLogMessage.MESSAGE("Target for \(variationGroupItem.idVariationGroup) is NOK ❌"))
                    }
                }
                groupCampaigns.append(FSCampaignCache(bucketCampaignItem.idCampaign, bucketCampaignItem.name, groupVar, bucketCampaignItem.type, bucketCampaignItem.slug))
            }
        }
        fsCampaignBucketCache.campaigns = groupCampaigns

        return fsCampaignBucketCache
    }

    func selectVariationWithHashMurMur(_ visitorId: String, _ variationGroup: FSVariationGroup) -> String? {
        // Before selected varaition have to check user id exist
        if !assignationHistory.isEmpty {
            FlagshipLogManager.Log(level: .INFO, tag: .BUCKETING, messageToDisplay: .BUCKETING_EXISTING_FILE)

            for itemKey in assignationHistory.keys {
                if itemKey == variationGroup.idVariationGroup { // Variation Group already exist, then return the saved one
                    FlagshipLogManager.Log(level: .INFO, tag: .BUCKETING, messageToDisplay: .BUCKETING_EXISTING_VARIATION(itemKey))

                    return assignationHistory[itemKey]
                }
            }
        }

        let hashAlloc: Int

        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: .MESSAGE("Apply MurMurHash Algo on customId"))

        //  We calculate the Hash allocation by the combonation of : visitorId + idVariationGroup
        let combinedId = variationGroup.idVariationGroup + visitorId
        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: .MESSAGE("The combined id for MurMurHash is :  \(combinedId)"))

        hashAlloc = Int(MurmurHash3.hash32(key: combinedId) % 100)

        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay: .MESSAGE("--- The hash is :  \(hashAlloc) ----"))

        var offsetAlloc = 0
        for item: FSVariation in variationGroup.variations {
            if hashAlloc < item.allocation + offsetAlloc {
                return item.idVariation
            }
            offsetAlloc += item.allocation
        }
        return nil
    }
}
