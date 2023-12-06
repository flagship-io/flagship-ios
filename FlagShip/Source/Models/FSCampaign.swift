//
//  FSCampaign.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

// ////////////////////////////////////
// ************ Campaign ********** //
// ////////////////////////////////////

class FSCampaign: Codable {
    public var idCampaign: String = ""
    public var slug: String = ""
    public var variationGroupId: String = ""
    public var type: String
    public var variation: FSVariation?
    public var name: String = ""
    public var variationGroupName: String = ""

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idCampaign = try values.decode(String.self, forKey: .idCampaign) } catch { self.idCampaign = "" }
        do { self.variationGroupId = try values.decode(String.self, forKey: .variationGroupId) } catch { self.variationGroupId = "" }
        do { self.variation = try values.decode(FSVariation.self, forKey: .variation) } catch { self.variation = nil }
        do { self.type = try values.decode(String.self, forKey: .type) } catch { self.type = "" }
        do { self.slug = try values.decode(String.self, forKey: .slug) } catch { self.slug = "" }
        do { self.name = try values.decode(String.self, forKey: .name) } catch { self.name = "" }
        do { self.variationGroupName = try values.decode(String.self, forKey: .variationGroupName) } catch { self.variationGroupName = "" }
    }

    init(_ idCampaign: String, _ nameCampaign: String, _ variationGroupId: String, _ nameVariationGroup: String, _ aType: String, _ aSlug: String) {
        self.idCampaign = idCampaign
        self.variationGroupId = variationGroupId
        self.type = aType
        self.name = nameCampaign
        self.variationGroupName = nameVariationGroup
        self.slug = aSlug
    }

    private enum CodingKeys: String, CodingKey {
        case idCampaign = "id"
        case variationGroupId
        case variation
        case type
        case slug
        case name
        case variationGroupName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.idCampaign, forKey: .idCampaign)
        try container.encode(self.variationGroupId, forKey: .variationGroupId)
        try container.encode(self.variationGroupName, forKey: .variationGroupName)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.slug, forKey: .slug)
        try container.encode(self.variation, forKey: .variation)
    }
}

// ////////////////////////////////////
// ************ Variation ********** //
// ////////////////////////////////////

class FSVariation: Codable {
    public var idVariation: String = ""
    public var modifications: FSModifications?
    public var allocation: Int
    public var reference: Bool = false
    public var name: String = ""

    init(idVariation: String, variationName: String, _ modifications: FSModifications?, isReference: Bool) {
        self.idVariation = idVariation
        self.modifications = modifications
        self.allocation = 0
        self.reference = isReference
        self.name = variationName
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.idVariation = try values.decode(String.self, forKey: .idVariation) } catch { self.idVariation = "" }
        do { self.modifications = try values.decode(FSModifications.self, forKey: .modifications) } catch { self.modifications = nil }
        do { self.allocation = try values.decode(Int.self, forKey: .allocation) } catch { self.allocation = 0 }
        do {
            self.reference = try values.decode(Bool.self, forKey: .reference)
        } catch {
            self.reference = false
        }
        do { self.name = try values.decode(String.self, forKey: .name) } catch { self.name = "" }
    }

    private enum CodingKeys: String, CodingKey {
        case idVariation = "id"
        case modifications
        case allocation
        case reference
        case name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.idVariation, forKey: .idVariation)
        try container.encode(self.reference, forKey: .reference)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.modifications, forKey: .modifications)

    }
}

 
 
