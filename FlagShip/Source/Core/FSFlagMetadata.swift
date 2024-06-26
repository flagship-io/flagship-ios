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

    public init(dico: [String: Any]) {
        campaignId = dico["campaignId"] as? String ?? ""
        variationGroupId = dico["variationGroupId"] as? String ?? ""
        variationId = dico["variationId"] as? String ?? ""
        isReference = false
        campaignType = dico["campaignType"] as? String ?? ""
        slug = dico["slug"] as? String ?? ""
        campaignName = dico["campaignName"] as? String ?? ""
        variationGroupName = dico["variationGroupName"] as? String ?? ""
        variationName = dico["variationName"] as? String ?? ""
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

//
/**
 * This status represent the flag status depend on visitor actions
 */
@objc enum FlagSynchStatus: Int {
    // When visitor is created
    case CREATED
    // When visitor context is updated
    case CONTEXT_UPDATED
    // When visitor Fetched flags
    case FLAGS_FETCHED
    // When visitor is authenticated
    case AUTHENTICATED
    // When visitor is unauthorised
    case UNAUTHENTICATED

    /**
      Return the string for the flag warning message.
      Note: No message for FLAGS_FETCHED state
     */
    func warningMessage(_ flagKey: String, _ visitorId: String)->String {
        var ret = ""
        switch self {
        case .CREATED:
            ret = "Visitor `\(visitorId)` has been created without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .CONTEXT_UPDATED:
            ret = "Visitor context for visitor `\(visitorId)` has been updated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .AUTHENTICATED:
            ret = "Visitor `\(visitorId)` has been authenticated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        case .UNAUTHENTICATED:
            ret = "Visitor `\(visitorId)` has been unauthenticated without calling `fetchFlags` method afterwards, the value of the flag `\(flagKey)` may be outdated."
        default:
            break
        }

        return ret
    }
}
