//
//  FSFlagMetadata.swift
//  Flagship
//
//  Created by Adel Ferguen on 29/05/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

@objc public class FSFlagMetadata: NSObject {
    public private(set) var campaignId: String = ""
    public private(set) var variationGroupId: String = ""
    public private(set) var variationId: String = ""
    public private(set) var isReference: Bool = false
    public private(set) var campaignType: String = ""
    public private(set) var slug: String = ""
    public private(set) var campaignName: String = ""
    public private(set) var variationGroupName: String = ""
    public private(set) var variationName: String = ""

    init(_ modification: FSModification?) {
        campaignId = modification?.campaignId ?? ""
        variationGroupId = modification?.variationGroupId ?? ""
        variationId = modification?.variationId ?? ""
        isReference = modification?.isReference ?? false
        campaignType = modification?.type ?? ""
        slug = modification?.slug ?? ""
        campaignName = modification?.campaignName ?? ""
        variationGroupName = modification?.variationGroupName ?? ""
        variationName = modification?.variationName ?? ""
    }

    public init(metadataDico: [String: Any]) {
        campaignId = metadataDico["campaignId"] as? String ?? ""
        variationGroupId = metadataDico["variationGroupId"] as? String ?? ""
        variationId = metadataDico["variationId"] as? String ?? ""
        isReference = false
        campaignType = metadataDico["campaignType"] as? String ?? ""
        slug = metadataDico["slug"] as? String ?? ""
        campaignName = metadataDico["campaignName"] as? String ?? ""
        variationGroupName = metadataDico["variationGroupName"] as? String ?? ""
        variationName = metadataDico["variationName"] as? String ?? ""
    }

    @objc public func toJson()->[String: Any] {
        return ["campaignId": campaignId,
                "campaignName": campaignName,
                "variationGroupId": variationGroupId,
                "variationGroupName": variationGroupName,
                "variationId": variationId,
                "variationName": variationName,
                "isReference": isReference,
                "campaignType": campaignType,
                "slug": slug]
    }
}
