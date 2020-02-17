//
//  FSBucketManager.swift
//  FlagShip-framework
//
//  Created by Adel on 21/11/2019.
//

import UIKit

class FSBucketManager: NSObject {
    
    
    let targetManager:FSTargetingManager!
    
    var matchedVariationGroup:[FSVariationGroup] = [] // Init with empty array
    
    var matchedCampaigns:[FSCampaignCache] = []
    
  //  var fsCampaignBucketCache:FSBucketCache!
    
    override init() {
        
        targetManager = FSTargetingManager()
       
    }
    
    
    
    /// this is the entry for bucketing , that give the campaign infos as we do in api decesion
    internal func bucketVariations(_ tupleId:TupleId, _ scriptBucket:FSBucket)->FSCampaigns?{
        
        /// Check the panic mode
        
        if (scriptBucket.panic == true){
            
            return nil
        }
        
        //check if the user exist in the cache , if yes then read his own modification from the cache
        
        // If not extract the variations
        
        //check the targetings and filter the variation he can run
       
        // Match before
        let resultBucketCache = matchTargetingForCustomID(scriptBucket, tupleId, scriptBucket.visitorConsolidation)
        
        // Save My bucketing
        resultBucketCache.saveMe()
        
        // Fill Campaign with value to be read by singleton
        return FSCampaigns(resultBucketCache)
    }
    
    
    /// Extract the variations where the user is allowed to seee
    
    internal func matchTargetingForCustomID(_ scriptBucket:FSBucket?, _ tupleId:TupleId,  _ visitorConsolidation:Bool)->FSBucketCache{
        
       let fsCampaignBucketCache = FSBucketCache(tupleId)
        
        matchedVariationGroup.removeAll()
        
        var groupCampaigns:[FSCampaignCache] = []
        var groupVar:[FSVariationGroupCache] = []
       
        groupCampaigns.removeAll()
        for bucketCampaignItem:FSBucketCampaign in scriptBucket!.campaigns{
            groupVar.removeAll()

            for variationGroupItem:FSVariationGroup in bucketCampaignItem.variationGroups{
                
                if (targetManager.isTargetingGroupIsOkay(variationGroupItem.targeting)){
                    
                    print("Target for \(variationGroupItem.idVariationGroup ?? "") is OKAY")
                    
                    
                    // select variation here
                    guard let variationIdSelected = selectVariationWithHashMurMur(tupleId, variationGroupItem, visitorConsolidation) else{
                        
                        print("probleme here don 't found the id variation selected")
                        continue
                        
                    }
                    
                    /// Get all modification according to id variation
                    
                    let variationCache:FSVariationCache = FSVariationCache(variationIdSelected)
                    
                    for itemVariation in variationGroupItem.variations{
                        
                        if (itemVariation.idVariation == variationIdSelected){
                            
                            variationCache.modification = itemVariation.modifications
                        }
                    }
                    
                    groupVar.append(FSVariationGroupCache(variationGroupItem.idVariationGroup, variationCache))

                    
                }else{
                    
                    print("Target for \(variationGroupItem.idVariationGroup ?? "") is NOK")

                }
            }
            groupCampaigns.append(FSCampaignCache(bucketCampaignItem.idCampaign, groupVar))
        }
        fsCampaignBucketCache.campaigns = groupCampaigns
        
        return fsCampaignBucketCache
    }
    
    
    internal func selectVariationWithHashMurMur(_ tupleId:TupleId?,_ variationGroup:FSVariationGroup, _ visitorConsolidation:Bool) -> String?{
        
        // Before selected varaition have to chck user id exist
        
        if (FSStorage.fileExists(String(format: "%@_%@.json", tupleId?.customId ?? "", tupleId?.fsUserId ?? "nil"), in: .documents)){
            
            FSLogger.FSlog(" The Buketing already exist Will Re check targeting for the selected variation ", .Campaign)

            let cachedObject = FSStorage.retrieve(String(format: "%@_%@.json",  tupleId?.customId ?? "",tupleId?.fsUserId ?? "nil"), from: .documents, as: FSBucketCache.self)
            
            for itemCached in cachedObject.campaigns{
                
                for subItemCached in itemCached.variationGroups{  /// Variation Group already exist, then return the saved one
                    
                    if (subItemCached.variationGroupId == variationGroup.idVariationGroup){
                        
                        return subItemCached.variation.variationId
                    }
                }
            }
        }
        
        let hashAlloc:Int
        if (visitorConsolidation && tupleId?.customId != nil){
            
            FSLogger.FSlog(" visitor consolidation is TRUE ", .Campaign)

            FSLogger.FSlog("Apply MurMurHash Algo on customId", .Campaign)

            hashAlloc = (Int(MurmurHash3.hash32(key: tupleId!.customId!) % 100))
            
        }else if (tupleId?.customId != nil){
            
              hashAlloc = (Int(MurmurHash3.hash32(key: tupleId!.customId!) % 100))
        }else{
            
            FSLogger.FSlog("Apply MurMurHash Algo on FS user id ", .Campaign)

            hashAlloc = (Int(MurmurHash3.hash32(key: tupleId!.fsUserId) % 100))
        }
        
            // Murmur the custom id
       
            print("hashAlloc ..........\(hashAlloc)")
            var offsetAlloc = 0
            for item:FSVariation in  variationGroup.variations{
                
                if(hashAlloc <= item.allocation + offsetAlloc){
                    
                    return item.idVariation
                }
                offsetAlloc += item.allocation
            }
            return nil
    }
}
