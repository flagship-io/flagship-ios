//
//  FSCampaigns.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

class FSCampaigns: Codable {
    // visitorId
    public var visitorId: String = ""
    // panic (sdk disabled if true)
    public var panic: Bool
    // list of campaign
    public var campaigns: [FSCampaign] = []
    // Account setting
    public var extras: FSExtras?
    
    // initialize
    init(_ customId: String, panic: Bool = false) {
        self.visitorId = customId
        self.panic = panic
        self.extras = nil 
    }
    
    // ********* This init from bucket cache model
    init(_ cacheCampaign: FSBucketCache) {
        self.visitorId = cacheCampaign.visitorId
        self.panic = false
        self.campaigns = cacheCampaign.getCampaignArray()
        self.extras = cacheCampaign.extras
    }
    
    /// Decoder
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        do { self.campaigns = try values.decode([FSCampaign].self, forKey: .campaigns) } catch { self.campaigns = [] }
        do { self.panic
            
            = try values.decode(Bool.self, forKey: .panic)
        } catch { self.panic = false }
        do { self.extras
            
            = try values.decode(FSExtras.self, forKey: .extras)
            
        } catch { self.extras = FSExtras(nil) }
    }
    
    /// Codings Keys
    private enum CodingKeys: String, CodingKey {
        case visitorId
        case campaigns
        case panic
        case extras
    }
    
    func getAllModification() -> [String: FSModification] {
        var ret: [String: FSModification] = [:]
        
        if !self.campaigns.isEmpty {
            for itemCamp in self.campaigns {
                if let aVariation = itemCamp.variation {
                    if let aValue = aVariation.modifications?.value {
                        for keyFlag in aValue.keys {
                            // Protection check
                            if let retValue = aValue[keyFlag] {
                                // Create Modification object
                                let modifObject = FSModification(aCampaign: itemCamp, aVariation: aVariation, valueForFlag: retValue)
                                ret.updateValue(modifObject, forKey: keyFlag)
                                
                            } else {
                                FlagshipLogManager.Log(level: .INFO, tag: .CAMPAIGNS, messageToDisplay: FSLogMessage.ERROR_ON_READ_FLAG(_key: keyFlag))
                            }
                        }
                    }
                }
            }
        }
        return ret
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.visitorId, forKey: .visitorId)
        try container.encode(self.panic, forKey: .panic)
        
  
        do { try container.encode(self.campaigns, forKey: .campaigns) } catch {
           // print(error)
            self.campaigns = []
        }
    }
}
