//
//  FSCacheVisitor.swift
//  Flagship
//
//  Created by Adel on 31/12/2021.
//

let CACHE_MODEL_VERSION: Double = 1.0

enum MIGRATION_MODEL: Double {
    case MIGRATION_MODEL_V1 = 2.0
    /// Next generation add here the updated models
}

public class FSCacheVisitor: Codable {
    var version: Double
    var data: FSCacheDataVistor?
    
    private enum CodingKeys: String, CodingKey {
        case version
        case data
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        do { self.version = try values.decode(Double.self, forKey: .version) } catch { self.version = 1.0 }
        /// In the future when update the migration plan will use the switch to select the correct model
        do { self.data = try values.decode(FSCacheDataVistor.self, forKey: .data) } catch { self.data = nil }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.version, forKey: .version)
        try container.encode(self.data, forKey: .data)
    }
    
    /// Wrapper from visitor to visitorCache
    init(_ visitor: FSVisitor) {
        self.version = CACHE_MODEL_VERSION
        self.data = FSCacheDataVistor(visitor)
    }
    
    /// Wrapper from visitor to visitorCache & oldest cache
    init(_ visitor: FSVisitor, assignationHistory: [String: String]) {
        self.version = CACHE_MODEL_VERSION
        self.data = FSCacheDataVistor(visitor)
    }
}

class FSCacheDataVistor: Codable {
    var visitorId: String?
    var anonymousId: String?
    var consent: Bool = true
    var context: [String: Any] = [:]
    var campaigns: [FSCacheCampaign] = [] /// Used on offline Mode  (utilisable en mode offline)
    var assignationHistory: [String: String] = [:] /// variationGroupId:variationId il garde tout l'historique pour éviter la realloc
    var emotionScoreAI: String?
    var eaiVisitorScored: Bool = false

    private enum CodingKeys: String, CodingKey {
        case visitorId
        case anonymousId
        case consent
        case context
        case campaigns
        case assignationHistory
        case emotionScoreAI
        case eaiVisitorScored
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        do { self.anonymousId = try values.decode(String.self, forKey: .anonymousId) } catch { self.anonymousId = "" }
        do { self.consent = try values.decode(Bool.self, forKey: .consent) } catch { self.consent = true }
        do { self.context = try values.decode([String: Any].self, forKey: .context) } catch { self.context = [:] }
        do { self.campaigns = try values.decode([FSCacheCampaign].self, forKey: .campaigns) } catch {
            self.campaigns = []
        }
        
        do { self.assignationHistory = try values.decode([String: String].self, forKey: .assignationHistory) } catch {
            self.assignationHistory = [:]
        }
        
        // Add socre for emotionAI
        do {
            self.emotionScoreAI = try values.decode(String.self, forKey: .emotionScoreAI)
        } catch {
            self.emotionScoreAI = nil
        }
        do { self.eaiVisitorScored = try values.decode(Bool.self, forKey: .eaiVisitorScored) } catch { self.eaiVisitorScored = false }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.visitorId, forKey: .visitorId)
        try container.encode(self.anonymousId, forKey: .anonymousId)
        try container.encode(self.consent, forKey: .consent)
        try container.encode(self.context, forKey: .context)
        try container.encode(self.campaigns, forKey: .campaigns)
        try container.encode(self.assignationHistory, forKey: .assignationHistory)
        try container.encode(self.emotionScoreAI, forKey: .emotionScoreAI)
        try container.encode(self.eaiVisitorScored, forKey: .eaiVisitorScored)
    }
    
    /// Wrapper from visitor to visitorCache
    init(_ visitor: FSVisitor) {
        /// Set the visitor
        self.visitorId = visitor.visitorId
        /// Set the anonymous
        self.anonymousId = visitor.anonymousId
        /// Set the consent
        self.consent = visitor.hasConsented
        /// Populate the context
        self.context.merge(visitor.getContext()) { _, new in new }
        /// Populate the campaign cache object
        /// Start by the initial cached campaigns
        if visitor.assignedVariationHistory.isEmpty == false {
            self.assignationHistory.merge(visitor.assignedVariationHistory) { _, new in new }
        }
        visitor.currentFlags.forEach { key, value in
            
            /// new elem to save in cache
            let newCacheCampaign = FSCacheCampaign(key, value)
            
//            /// Check if the campaign of the element to save if not already saved
//            /// if it is then will merge the flags
            let exist = self.campaigns.contains(where: { elemCacheCamp in

                if newCacheCampaign.campaignId == elemCacheCamp.campaignId {
                    /// Merge the flags
                    elemCacheCamp.flags.merge(newCacheCampaign.flags) { _, new in new }
                    return true
                } else {
                    return false
                }
            })
            
            if !exist { /// The campaign id for this element is not already added to cache
                self.campaigns.append(newCacheCampaign)
            }
            
            //// In the same time create asssigned history
            self.assignationHistory[newCacheCampaign.variationGroupId] = newCacheCampaign.variationId
        }
        
        
        // Set the emotionSocreAI
        self.emotionScoreAI = visitor.emotionSocreAI
        // Set emotionScored
        self.eaiVisitorScored = visitor.eaiVisitorScored
    }
}

class FSCacheCampaign: Codable {
    var campaignId: String
    var variationGroupId: String
    var variationId: String
    var isReference: Bool
    var type: String
    var slug: String
    var activated: Bool
    var flags: [String: Any] = [:]
    
    var campaignName: String
    var variationGroupName: String
    var variationName: String
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do { self.campaignId = try values.decode(String.self, forKey: .campaignId) } catch { self.campaignId = "" }
        do { self.variationGroupId = try values.decode(String.self, forKey: .variationGroupId) } catch { self.variationGroupId = "" }
        do { self.variationId = try values.decode(String.self, forKey: .variationId) } catch { self.variationId = "" }
        do { self.isReference = try values.decode(Bool.self, forKey: .isReference) } catch { self.isReference = true }
        do { self.activated = try values.decode(Bool.self, forKey: .activated) } catch { self.activated = true }
        do { self.type = try values.decode(String.self, forKey: .type) } catch { self.type = "" }
        do { self.slug = try values.decode(String.self, forKey: .slug) } catch { self.slug = "" }
        do { self.flags = try values.decode([String: Any].self, forKey: .flags) } catch { self.flags = [:] }
        
        do { self.campaignName = try values.decode(String.self, forKey: .campaignName) } catch { self.campaignName = "" }
        do { self.variationGroupName = try values.decode(String.self, forKey: .variationGroupName) } catch { self.variationGroupName = "" }
        do { self.variationName = try values.decode(String.self, forKey: .variationName) } catch { self.variationName = "" }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.campaignId, forKey: .campaignId)
        try container.encode(self.variationGroupId, forKey: .variationGroupId)
        try container.encode(self.variationId, forKey: .variationId)
        try container.encode(self.isReference, forKey: .isReference)
        try container.encode(self.activated, forKey: .activated)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.slug, forKey: .slug)

        /// Encode flags
        try container.encode(self.flags, forKey: .flags)
        
        try container.encode(self.campaignName, forKey: .campaignName)
        try container.encode(self.variationGroupName, forKey: .variationGroupName)
        try container.encode(self.variationName, forKey: .variationName)
    }
    
    private enum CodingKeys: String, CodingKey {
        case campaignId
        case variationGroupId
        case variationId
        case isReference
        case type
        case slug
        case activated
        case flags
        
        case campaignName
        case variationGroupName
        case variationName
    }
    
    /// Wrapper for FSModification ----> to FSCacheCampaign
    init(_ key: String, _ modifObject: FSModification) {
        self.campaignId = modifObject.campaignId
        self.variationGroupId = modifObject.variationGroupId
        self.variationId = modifObject.variationId
        self.isReference = modifObject.isReference
        self.type = modifObject.type
        self.activated = false /// later refractor
        self.flags[key] = modifObject.value
        self.slug = modifObject.slug
        
        self.campaignName = modifObject.campaignName
        self.variationGroupName = modifObject.variationGroupName
        self.variationName = modifObject.variationName
    }
    
    func getFlagsFromCachedCampaign() -> [String: FSModification] {
        var result: [String: FSModification] = [:]
        for item in self.flags.keys {
            if let value = self.flags[item] {
                result[item] = FSModification(cacheCamp: self, valueForFlag: value)
            }
        }
        return result
    }
}

class FSCacheDataVistorBis: Codable {}
