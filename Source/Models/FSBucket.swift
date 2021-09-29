//
//  FSBucket.swift
//  FlagShip-framework
//
//  Created by Adel on 19/11/2019.
//

import Foundation

//// Response Bucket
internal class FSBucket: Decodable {

    let visitorConsolidation: Bool
    let campaigns: [FSBucketCampaign]
    let panic: Bool

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)

        /// For This version the consolidation is not available , the visitorConsolidation is false
        ///      do{ self.visitorConsolidation         = try values.decode(Bool.self, forKey: .visitorConsolidation)} catch{ self.visitorConsolidation = false}
        /// Set the consolidation to false
        self.visitorConsolidation = false

        do { self.campaigns                    = try values.decode([FSBucketCampaign].self, forKey: .campaigns)} catch { self.campaigns = []}
        do { self.panic                        = try values.decode(Bool.self, forKey: .panic)} catch { self.panic = false}
    }

    private enum CodingKeys: String, CodingKey {
        case visitorConsolidation
        case campaigns
        case panic
    }

    /// The default construct
    init() {

        self.visitorConsolidation = true
        self.panic = true
        self.campaigns = []
    }
}

////// Campaigns
class FSBucketCampaign: Decodable {

    let idCampaign: String!
    let type: String!
    let variationGroups: [FSVariationGroup]

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idCampaign              = try values.decode(String.self, forKey: .idCampaign)} catch { self.idCampaign = ""}
        do { self.type                    = try values.decode(String.self, forKey: .type)} catch { self.type = ""}
        do { self.variationGroups         = try values.decode([FSVariationGroup].self, forKey: .variationGroups)} catch { self.variationGroups = []}
    }

    private enum CodingKeys: String, CodingKey {

        case idCampaign = "id"
        case type
        case variationGroups
    }

}

class FSVariationGroup: Decodable {

    let idVariationGroup: String!
    let targeting: FSTargeting?
    let variations: [FSVariation]

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idVariationGroup        = try values.decode(String.self, forKey: .idVariationGroup)} catch { self.idVariationGroup = ""}
        do { self.targeting               = try values.decode(FSTargeting.self, forKey: .targeting)} catch { self.targeting = nil}
        do { self.variations              = try values.decode([FSVariation].self, forKey: .variations)} catch { self.variations = []}

    }

    private enum CodingKeys: String, CodingKey {

        case idVariationGroup = "id"
        case targeting
        case variations
    }

}
