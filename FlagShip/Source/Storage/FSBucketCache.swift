//
//  FSBucketCache.swift
//  FlagShip-framework
//
//  Created by Adel on 29/11/2019.
//

import Foundation
// Represent the object saved for each user

internal class FSBucketCache {

    var visitorId: String
    var campaigns: [FSCampaignCache]!  // Refractor
    
    internal init(_ visitorId: String) {

        self.visitorId = visitorId
        self.campaigns = []
    }

    internal func getCampaignArray() -> [FSCampaign] {

        var result: [FSCampaign] = []

        if self.campaigns != nil {

            for item: FSCampaignCache in self.campaigns {

                let campaignResult = item.convertFSCampaignCachetoFSCampaign()

                if campaignResult.variation != nil {

                    result.append(campaignResult)
                }
            }
        }
        return result
    }
}

// Campaign contain liste variation groups
internal class FSCampaignCache {

    var campaignId: String!
    
    var nameCampaign:String = ""

    var variationGroups: [FSVariationGroupCache]

    init(_ campaignId: String!, _ campaignName:String, _ variationGroups: [FSVariationGroupCache]) {

        self.campaignId = campaignId

        self.variationGroups = variationGroups
        
        self.nameCampaign = campaignName
    }

    internal func convertFSCampaignCachetoFSCampaign() -> FSCampaign {

    let campaign: FSCampaign = FSCampaign(campaignId,nameCampaign,  self.variationGroups.first?.variationGroupId ?? "" , self.variationGroups.first?.name ?? "", "") 
        
        /// See later the type in bucketing mode

        campaign.variation =  variationGroups.first?.getFSVariation()

        return campaign
    }
}

// Variation Groupe contain variation
internal class FSVariationGroupCache{

    var variationGroupId: String!
    
    var name:String = ""
    
    var variation: FSVariationCache!

    init (_ variationGroupId: String, _ nameVarGroup:String, _ variationCache: FSVariationCache ) {

        self.variationGroupId = variationGroupId

        self.variation = variationCache
        
        self.name = nameVarGroup
    }
    
    
    internal func getFSVariation() -> FSVariation {

        return FSVariation(idVariation: variation.variationId, variationName: variation.variationName, variation.modification, isReference: variation.reference)

     }
}

// Variation
internal class FSVariationCache /*: Codable */{

    var variationId: String = ""
    
    var variationName: String = ""

    var modification: FSModifications?
    
    var reference: Bool = false

    init (_ variationId: String) {

        self.variationId = variationId
    }
}
