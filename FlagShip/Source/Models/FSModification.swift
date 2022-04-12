//
//  FSModification.swift
//  Flagship
//
//  Created by Adel on 29/09/2021.
//

import Foundation

public class FSModification {
    /// CampaignId
    let campaignId:String
    /// Variation Group
    let variationGroupId:String
    /// VariationId
    let variationId:String
    /// Is reference
    var isReference:Bool = false
    /// Type
    var type:String
    /// Slug
    var slug:String
    /// Value for flag
    var value:Any
    
    
    init(campId:String, varGroupId:String,varId:String,isRef:Bool = false,typeOfTest:String, aSlug:String, val:Any){
        
        /// Set variation Id
        campaignId = campId
        /// Set variation group id
        variationGroupId = varGroupId
        /// Set variation id
        variationId = varId
        /// Set reference
        isReference = isRef
        /// Set type
        type = typeOfTest
        /// Slug
        slug = aSlug
        /// Set value
        value = val
    }
}
