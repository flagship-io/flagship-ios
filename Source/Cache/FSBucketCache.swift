//
//  FSBucketCache.swift
//  FlagShip-framework
//
//  Created by Adel on 29/11/2019.
//

import Foundation


/// Represent the object saved for each user

internal class FSBucketCache: Codable {
    
    var visitorId:String
    
    var campaigns:[FSCampaignCache]!
    
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        do{ self.visitorId              = try values.decode(String.self, forKey: .visitorId)} catch{ self.visitorId = "error"}
        do{ self.campaigns              = try values.decode([FSCampaignCache].self, forKey: .campaigns)} catch{ self.campaigns = []}

    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case visitorId
        case campaigns
     }
    
    
    internal init(_ visitorId:String){
        
        self.visitorId = visitorId
        self.campaigns = []
    }
    
    
    internal func getCampaignArray()->[FSCampaign]{
        
        var result:[FSCampaign] = []
        
        if(self.campaigns != nil){
            
            for item:FSCampaignCache in self.campaigns{
                
                let campaignResult = item.convertFSCampaignCachetoFSCampaign()
                
                if (campaignResult.variation != nil){
                    
                    result.append(campaignResult)
                }
            }
        }
        return result
    }
    
    internal func saveMe(){
        
        FSStorage.store(self, to: .documents, as: String(format: "%@.json", self.visitorId))
    }

}

//// Campaign contain liste variation groups
internal class FSCampaignCache:Codable{
    
    var campaignId:String!
    
    var variationGroups:[FSVariationGroupCache]
    

    init(_ campaignId:String!, _ variationGroups:[FSVariationGroupCache]) {
        
        self.campaignId = campaignId
        
        self.variationGroups = variationGroups
    }
    
    
    internal func convertFSCampaignCachetoFSCampaign()->FSCampaign{
        
        let campaign:FSCampaign = FSCampaign(campaignId, self.variationGroups.first?.variationGroupId ?? "")
        
        campaign.variation =  variationGroups.first?.getFSVariation()
        
        return campaign
    }
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        do{ self.campaignId              = try values.decode(String.self, forKey: .campaignId)} catch{ self.campaignId = ""}
        do{ self.variationGroups             = try values.decode([FSVariationGroupCache].self, forKey: .variationGroups)} catch{ self.variationGroups = []}
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case campaignId
        case variationGroups
     }
    
}


/// Variation Groupe contain variation
internal class FSVariationGroupCache:Codable {
    
    var variationGroupId:String!
    
    var variation:FSVariationCache!
    
    init (_ variationGroupId:String ,_ variationCache:FSVariationCache ){
        
        self.variationGroupId = variationGroupId
        
        self.variation = variationCache
        
    }
    
    internal func getFSVariation()->FSVariation{
        
        return FSVariation(idVariation: variation.variationId, variation.modification)
        
     }
    
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        do{ self.variationGroupId            = try values.decode(String.self, forKey: .variationGroupId)} catch{ self.variationGroupId = ""}
        do{ self.variation                   = try values.decode(FSVariationCache.self, forKey: .variation)} catch{ self.variation = nil}
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case variationGroupId
        case variation
     }
    
}


/// Variation
internal class FSVariationCache:Codable{
    
    var variationId:String = ""
    
    var modification:FSModifications?
    
    init (_ variationId:String){
        
        self.variationId = variationId
    }
    
    
    required public  init(from decoder: Decoder) throws{
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        
        do{ self.variationId            = try values.decode(String.self, forKey: .variationId)} catch{ self.variationId = ""}
        do{ self.modification           = try values.decode(FSModifications.self, forKey: .modification)} catch{ self.modification = nil}
    }
    
    
    private enum CodingKeys: String, CodingKey {
        
        case variationId
        case modification
     }
    
}


