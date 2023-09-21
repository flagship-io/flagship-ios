//
//  FSModification.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

public class FSModification {
    // CampaignId
    let campaignId:String
    // Variation Group
    let variationGroupId:String
    // VariationId
    let variationId:String
    // Is reference
    var isReference:Bool = false
    // Type
    var type:String
    // Slug
    var slug:String
    // Value for flag
    var value:Any
    // CampaignName
    let campaignName:String
    // VariationGroupName
    let variationGroupName:String
    // VariationName
    let variationName:String
    
    // init from campaign and variation
    internal init(aCampaign:FSCampaign,aVariation:FSVariation, valueForFlag:Any){
        
        // Set campId
        campaignId = aCampaign.idCampaign
        
        // Set Name
        campaignName = aCampaign.name
        
        // Set type
        type = aCampaign.type
        
        // Slug
        slug = aCampaign.slug
        
        // Set variation group id
        variationGroupId = aCampaign.variationGroupId
        
        // Set variation name
        variationGroupName = aCampaign.variationGroupName
        
        // Set variation id
        variationId = aVariation.idVariation
        
        // Set Name for variation
        variationName = aVariation.name
        
        // Set reference
        isReference = aVariation.reference
 
        // Set value
        value = valueForFlag
        
    }
    
    
    // Init from cache
    internal init(cacheCamp:FSCacheCampaign, valueForFlag:Any){
        
        // Set campId
        campaignId = cacheCamp.campaignId
        // Set Name
        campaignName = cacheCamp.campaignName
        
        // Set type
        type = cacheCamp.type
        
        // Slug
        slug = cacheCamp.slug
        
        // Set variation group id
        variationGroupId = cacheCamp.variationId
        // Set variation name
        variationGroupName = cacheCamp.variationGroupName
        
        // Set variation id
        variationId = cacheCamp.variationId
        // Set Name for variation
        variationName = cacheCamp.variationName
        
        // Set reference
        isReference = cacheCamp.isReference
 
        // Set value
        value = valueForFlag
    }
}
