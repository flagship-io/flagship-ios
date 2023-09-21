//
//  FSCampaigns.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

internal class FSCampaigns:Decodable {
    // visitorId
    public var visitorId: String = ""
    // panic (sdk disabled if true)
    public var panic: Bool
    // list of campaign
    public var campaigns: [FSCampaign] = []
    // initialize
    internal init(_ customId: String, panic:Bool = false) {
        
        self.visitorId = customId
        self.panic = panic
    }
    
    
    // ********* This init from bucket cache model
    internal init(_ cacheCampaign: FSBucketCache) {

        self.visitorId = cacheCampaign.visitorId
        self.panic     = false
        self.campaigns = cacheCampaign.getCampaignArray()
    }
    
    /// Decoder
    required public  init(from decoder: Decoder) throws {
        
        let values     = try decoder.container(keyedBy: CodingKeys.self)
        do { self.visitorId              = try values.decode(String.self, forKey: .visitorId)}catch{self.visitorId = ""}
        do { self.campaigns              = try values.decode([FSCampaign].self, forKey: .campaigns)} catch { self.campaigns = []}
        do { self.panic                  = try values.decode(Bool.self, forKey: .panic)} catch { self.panic = false}
    }
    
    /// Codings Keys
    private enum CodingKeys: String, CodingKey {
        case visitorId
        case campaigns
        case panic
    }
    
    
    internal func getAllModification()->[String:FSModification]{
        
        var ret:[String:FSModification] = [:]
        
        if (!self.campaigns.isEmpty) {
            
            for itemCamp in self.campaigns {
                
                if let aVariation = itemCamp.variation{
                    
                    if let aValue = aVariation.modifications?.value{
                        
                        for keyFlag in aValue.keys{
                            // Protection check
                            if let retValue = aValue[keyFlag]{
                                // Create Modification object
                                let modifObject = FSModification(aCampaign: itemCamp, aVariation: aVariation, valueForFlag: retValue)
                                ret.updateValue(modifObject, forKey: keyFlag)
                               
                            }else{
                                
                                FlagshipLogManager.Log(level: .INFO, tag: .CAMPAIGNS, messageToDisplay:FSLogMessage.ERROR_ON_READ_FLAG(_key: keyFlag))
                            }
                        }
                    }
                }
            }
            
        }
        return ret
    }
    
}
