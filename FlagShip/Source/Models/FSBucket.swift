//
//  FSBucket.swift
//  FlagShip-framework
//
//  Created by Adel on 19/11/2019.
//

import Foundation

//// Response Bucket
class FSBucket: Decodable {
    let visitorConsolidation: Bool
    let campaigns: [FSBucketCampaign]
    let panic: Bool
    let accountSettings: FSAccountSettings?

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.visitorConsolidation = false

        do { self.campaigns = try values.decode([FSBucketCampaign].self, forKey: .campaigns) } catch { self.campaigns = [] }
        do { self.panic = try values.decode(Bool.self, forKey: .panic) } catch { self.panic = false }
        do { self.accountSettings = try values.decode(FSAccountSettings.self, forKey: .accountSettings) } catch {
            self.accountSettings = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case visitorConsolidation
        case campaigns
        case panic
        case accountSettings
    }

    init() {
        self.visitorConsolidation = true
        self.panic = true
        self.campaigns = []
        self.accountSettings = nil
    }
}

// Campaigns
class FSBucketCampaign: Decodable {
    var idCampaign: String = ""
    var type: String = ""
    var variationGroups: [FSVariationGroup]
    var name: String = ""
    var slug: String = ""

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idCampaign = try values.decode(String.self, forKey: .idCampaign) } catch { self.idCampaign = "" }
        do { self.type = try values.decode(String.self, forKey: .type) } catch { self.type = "" }
        do { self.variationGroups = try values.decode([FSVariationGroup].self, forKey: .variationGroups) } catch { self.variationGroups = [] }
        do { self.name = try values.decode(String.self, forKey: .name) } catch { self.name = "" }
        do { self.slug = try values.decode(String.self, forKey: .slug) } catch { self.slug = "" }
    }

    private enum CodingKeys: String, CodingKey {
        case idCampaign = "id"
        case type
        case variationGroups
        case name
        case slug
    }
}

class FSVariationGroup: Decodable {
    var idVariationGroup: String = ""
    let targeting: FSTargeting?
    let variations: [FSVariation]
    var name: String = ""

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idVariationGroup = try values.decode(String.self, forKey: .idVariationGroup) } catch { self.idVariationGroup = "" }
        do { self.targeting = try values.decode(FSTargeting.self, forKey: .targeting) } catch { self.targeting = nil }
        do { self.variations = try values.decode([FSVariation].self, forKey: .variations) } catch { self.variations = [] }
        do { self.name = try values.decode(String.self, forKey: .name) } catch { self.name = "" }
    }

    private enum CodingKeys: String, CodingKey {
        case idVariationGroup = "id"
        case targeting
        case variations
        case name
    }
}
