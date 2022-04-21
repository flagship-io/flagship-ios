//
//  FSBucketingManager.swift
//  Flagship
//
//  Created by Adel on 26/10/2021.
//

import Foundation


internal let  SemaphoreTimeOut:TimeInterval = 2


internal class FSBucketingManager:FSDecisionManager, FSPollingScriptDelegate{
    
    var pollingScript:FSPollingScript?
    var _scriptBucket:FSBucket?
    var _scriptError:FSError?
    var targetManager: FSTargetingManager
    var matchedVariationGroup: [FSVariationGroup] = [] // Init with empty array
    var matchedCampaigns: [FSCampaignCache] = []
    let fsQueue = DispatchQueue(label: "com.flagship.queue", attributes: .concurrent)
    
    internal var scriptBucket: FSBucket? {

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
    
    internal var scriptError: FSError? {

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
    
    /// init Manager
     init(service:FSService,userId: String, currentContext: [String : Any], _ pollingTime:TimeInterval) {
         
        self.targetManager = FSTargetingManager()

        super.init(service: service, userId: userId, currentContext: currentContext)
         
        /// Create polling script
        self.pollingScript = FSPollingScript(service: super.networkService, pollingTime: pollingTime, delegate: self)
        
        /// Launch the script
        self.launchPolling()
    }
    
    override func getCampaigns(_ currentContext:[String:Any],withConsent:Bool,completion: @escaping (FSCampaigns?, Error?) -> Void){
        
        DispatchQueue.main.async {
            
            /// Set the context before running the bucket algorithm
            self.targetManager.currentContext = currentContext
            self.targetManager.userId = self.userId
            
            if let aScriptBucket = self.scriptBucket {
                let aCampaigns = self.bucketVariations(self.userId,aScriptBucket)
                completion(aCampaigns, self.scriptError)
                
                /// In separate thread send the context
                /// Before send context check if the user is consented
                if withConsent{
                    
                    /// Send the keys/values context
                    DispatchQueue(label: "flagship.contextKey.queue").async {
                        self.sendKeyContext(currentContext)
                    }
                }
            }else{
                completion(nil, self.scriptError)
            }
        }
    }
    
    /// Launch polling
    override func launchPolling() {
        self.pollingScript?.launchPolling()
    }


    /// Delegate -- The polling process will trigger this callback
    func onGetScript(_ newBucketing: FSBucket?, _ error: FSError?) {
        /// Update the status
        
        if let aNewBuckting = newBucketing {
            Flagship.sharedInstance.updateStatus(aNewBuckting.panic ? .PANIC_ON : .READY)
        }
        
        /// Update bucketing
        self.scriptBucket = newBucketing
        /// Update script error
        self.scriptError = error
    }
    
    /// This is the entry for bucketing , that give the campaign infos as we do in api decesion
    internal func bucketVariations(_ visitorId: String, _ scriptBucket: FSBucket) -> FSCampaigns? {

        /// Check the panic mode

        if scriptBucket.panic == true {
            
            return FSCampaigns(visitorId, panic: true)
        }

        // check if the user exist in the cache , if yes then read his own modification from the cache

        // If not extract the variations

        // check the targetings and filter the variation he can run

        // Match before
        let resultBucketCache = matchTargetingForCustomID(scriptBucket, visitorId)

        // Save My bucketing
       // resultBucketCache.saveMe()

        // Fill Campaign with value to be read by singleton
        return FSCampaigns(resultBucketCache)
    }
    
    /// Extract the variations where the user is allowed to seee

    internal func matchTargetingForCustomID(_ scriptBucket: FSBucket?, _ visitorId: String) -> FSBucketCache {

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
                        
                        FlagshipLogManager.Log(level: .ALL, tag:.ALLOCATION, messageToDisplay:FSLogMessage.MESSAGE("Target for \(variationGroupItem.idVariationGroup ?? "") is OKAY"))
                        
                        // select variation here
                        guard let variationIdSelected = selectVariationWithHashMurMur(visitorId, variationGroupItem) else {

                            //    // FSLogger.FSlog("probleme here don 't found the id variation selected", .Campaign)
                            
                            FlagshipLogManager.Log(level: .ALL, tag:.BUCKETING, messageToDisplay:FSLogMessage.MESSAGE("Problem here don 't found the id variation selected"))
                            continue
                        }

                        /// Get all modification according to id variation

                        let variationCache: FSVariationCache = FSVariationCache(variationIdSelected)

                        for itemVariation in variationGroupItem.variations {

                            if itemVariation.idVariation == variationIdSelected {

                                /// the variationIdSelected is found , populate the attributes
                                variationCache.modification = itemVariation.modifications
                                variationCache.reference = itemVariation.reference
                            }
                        }

                        groupVar.append(FSVariationGroupCache(variationGroupItem.idVariationGroup, variationCache))

                    } else {
                        
                        FlagshipLogManager.Log(level: .ALL, tag:.BUCKETING, messageToDisplay:FSLogMessage.MESSAGE("Target for \(variationGroupItem.idVariationGroup ?? "") is NOK"))
                    }
                }
                groupCampaigns.append(FSCampaignCache(bucketCampaignItem.idCampaign, groupVar))
            }

        }
        fsCampaignBucketCache.campaigns = groupCampaigns

        return fsCampaignBucketCache
    }
    
    internal func selectVariationWithHashMurMur(_ visitorId: String, _ variationGroup: FSVariationGroup) -> String? {


        
        // Before selected varaition have to check user id exist

        if FSStorage.fileExists(String(format: "%@.json", visitorId), in: .documents) {
            
            FlagshipLogManager.Log(level: .INFO, tag: .BUCKETING, messageToDisplay: .BUCKETING_EXISTING_FILE)

            guard let cachedObject = FSStorage.retrieve(String(format: "%@.json", visitorId), from: .documents, as: FSCacheVisitor.self) else {

                FlagshipLogManager.Log(level: .INFO, tag: .BUCKETING, messageToDisplay: .ERROR_ON_READ_FILE)
                
                return nil
            }
            
            if let cachedData = cachedObject.data{
                
                for itemKey in cachedData.assignationHistory.keys{
                    
                    if itemKey  == variationGroup.idVariationGroup { /// Variation Group already exist, then return the saved one
                        
                        FlagshipLogManager.Log(level: .INFO, tag: .BUCKETING, messageToDisplay:.BUCKETING_EXISTING_VARIATION(itemKey))

                        return cachedData.assignationHistory[itemKey]
                        
                    }
                }
            }
            
        }

        let hashAlloc: Int
        
        
        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay:.MESSAGE("Apply MurMurHash Algo on customId"))

        /// We calculate the Hash allocation by the combonation of : visitorId + idVariationGroup
        let combinedId = variationGroup.idVariationGroup + visitorId
        FlagshipLogManager.Log(level: .ALL, tag: .BUCKETING, messageToDisplay:.MESSAGE("The combined id for MurMurHash is :  \(combinedId)"))


        hashAlloc = (Int(MurmurHash3.hash32(key: combinedId) % 100))

        var offsetAlloc = 0
        for item: FSVariation in  variationGroup.variations {

            if hashAlloc < item.allocation + offsetAlloc {

                return item.idVariation
            }
            offsetAlloc += item.allocation
        }
        return nil
    }
    
    
    private func sendKeyContext(_ cuurentContext:[String : Any]){
        
        if let aScriptBucketing = self.scriptBucket{
            /// Check if no panic mode
            if (aScriptBucketing.panic == false){
                /// send the key context
                self.networkService.sendkeyValueContext(cuurentContext)
            }
            
           
        }
    }

}
