//
//  FSBatch.swift
//  Flagship
//
//  Created by Adel Ferguen on 17/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class FSBatch: FSTracking {
    var items: [FSTrackingProtocol] = []

    override public init() {
        super.init()
        self.type = .BATCH
    }

    init(_ listOfHit: [FSTrackingProtocol]) {
        super.init()
        // Set the envId
        self.envId = listOfHit.first?.envId
        // Set the type
        self.type = .BATCH
        // Set the Data Source
        self.dataSource = "APP"
        // Insert the hits
        self.items.append(contentsOf: listOfHit)
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    /// :nodoc:
    override public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        // Set Type
        customParams.updateValue(self.type.typeString, forKey: "t")
        // Set Client Id
        customParams.updateValue(self.envId ?? "", forKey: "cid") //// Rename it
        // Set Data source
        customParams.updateValue(self.dataSource, forKey: "ds")
        var listsForHKey: [[String: Any]] = []

        // Fill the list of hit thant contain a batch
        for item: FSTrackingProtocol in self.items {
            listsForHKey.append(item.bodyTrack)
        }
        customParams.updateValue(listsForHKey, forKey: "h")
        return customParams
    }
}

////////////////////
// Activate class //
////////////////////

let internal_exposure_flag = "internal_exposure_flag"
let internal_exposure_visitor = "internal_exposure_visitor"

class Activate: FSTrackingProtocol, Codable {
    var createdAt: TimeInterval = 0

    func isValid() -> Bool {
        return true
    }

    var id: String = ""

    var anonymousId: String?

    var visitorId: String?

    var type: FSTypeTrack

    var fileName: String!

    var envId: String?

    // VariationId
    var variationId: String?
    // Variation GroupId
    var variationGroupeId: String?

    // Exposed flag information
    var exposure_flag: String?
    var exposure_visitor: String?

    init(_ visitorId: String, _ anonymousId: String?, modification: FSModification, _ pExposedFlagInfoString: String? = nil, _ pExposedVisitorInfoString: String? = nil) {
        self.createdAt = Date().timeIntervalSince1970
        self.envId = Flagship.sharedInstance.envId
        self.visitorId = visitorId
        self.anonymousId = anonymousId
        self.variationId = modification.variationId
        self.variationGroupeId = modification.variationGroupId
        self.type = .ACTIVATE
        self.exposure_flag = pExposedFlagInfoString
        self.exposure_visitor = pExposedVisitorInfoString
    }

    public var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set client Id
        customParams.updateValue(self.envId ?? "", forKey: "cid")
        // VariationId
        customParams.updateValue(self.variationId ?? "", forKey: "vaid")
        // Variation GroupId
        customParams.updateValue(self.variationGroupeId ?? "", forKey: "caid")
        // Set visitor id
        customParams.updateValue(self.visitorId ?? "", forKey: "vid")
        // Set anonymous Id if is defined
        if let aId = anonymousId {
            customParams.updateValue(aId, forKey: "aid")
        }
        /// Add qt entries
        /// Time difference between when the hit was created and when it was sent
        let qt = Date().timeIntervalSince1970 - self.createdAt
        customParams.updateValue(qt.rounded(), forKey: "qt")

        // Set exposed flag info
        if let aExposedFlagInfoString = exposure_flag {
            customParams.updateValue(aExposedFlagInfoString, forKey: internal_exposure_flag)
        }

        // Set exposed visitor info
        if let aExposedVisitorInfoString = exposure_visitor {
            customParams.updateValue(aExposedVisitorInfoString, forKey: internal_exposure_visitor)
        }
        return customParams
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // visitorId
        do { self.visitorId = try values.decode(String.self, forKey: .visitorId) } catch { self.visitorId = "" }
        // anonymousId
        do { self.anonymousId = try values.decode(String.self, forKey: .anonymousId) } catch { /* error on decode aid */ }
        // envid
        do { self.envId = try values.decode(String.self, forKey: .envId) } catch { /* error on deocde envId*/ }
        // variationId
        do { self.variationId = try values.decode(String.self, forKey: .variationId) } catch { /* error on decode variationId*/ }
        // variationGroupeId
        do { self.variationGroupeId = try values.decode(String.self, forKey: .variationGroupeId) } catch { /* error on decode variationGroupeId*/ }

        // Exposed flag info
        do { self.exposure_flag = try values.decode(String.self, forKey: .exposure_flag) } catch {}
        // Exposed Visitor info
        do { self.exposure_visitor = try values.decode(String.self, forKey: .exposure_visitor) } catch {}

        self.type = .ACTIVATE

        do {
            self.createdAt = try values.decode(Double.self, forKey: .createdAt)

        } catch {
            self.createdAt = 0
        }
    }

    private enum CodingKeys: String, CodingKey {
        case visitorId = "vid"
        case anonymousId = "aid"
        case envId = "cid"
        case variationId = "vaid"
        case variationGroupeId = "caid"
        // Created time
        case createdAt = "qt" // See later the optional
        // Those keys for internal use only not forwarded to activate tracking
        case exposure_flag = "internal_exposure_flag"
        case exposure_visitor = "internal_exposure_visitor"
    }

    func getExposedInfo() -> FSExposedInfo? {
        if let dataExposedFalg = self.exposure_flag?.data(using: .utf8), let dataExposedVisitor = self.exposure_visitor?.data(using: .utf8) {
            do {
                if let dicoExposedFalg = (try? JSONSerialization.jsonObject(with: dataExposedFalg, options: [])) as? [String: Any] {
                    let expoFlag = FSExposedFlag(expoedInfo: dicoExposedFalg)

                    if let dicoExposedVisitor = (try? JSONSerialization.jsonObject(with: dataExposedVisitor, options: [])) as? [String: Any] {
                        let expoVisitor = FSVisitorExposed(dico: dicoExposedVisitor)
                        return FSExposedInfo(exposedFlag: expoFlag, visitorExposed: expoVisitor)
                    }
                }
            }
        }
        return nil
    }

    func description() -> String {
        do {
            let stringDescription = try JSONSerialization.data(withJSONObject: self.bodyTrack as Any, options: .prettyPrinted)
            return "\(stringDescription.prettyPrintedJSONString ?? "")"

        } catch {
            return ""
        }
    }
}

class ActivateBatch {
    var listActivate: [FSTrackingProtocol] = []
    var envId: String = ""
    var currentActivate: FSTrackingProtocol?

    init(pCurrentActivate: FSTrackingProtocol?) {
        self.currentActivate = pCurrentActivate
        self.envId = Flagship.sharedInstance.envId ?? ""
    }

    func addListOfElement(_ list: [FSTrackingProtocol]) {
        self.listActivate.append(contentsOf: list)
    }

    public var bodyTrack: [String: Any] {
        var ret: [[String: Any]] = []

        if let aCurrentActivate = self.currentActivate {
            var currentElemToAdd = aCurrentActivate.bodyTrack
            currentElemToAdd.removeValue(forKey: internal_exposure_flag)
            currentElemToAdd.removeValue(forKey: internal_exposure_visitor)
            ret.append(currentElemToAdd)
        }

        for item in self.listActivate {
            var elemToAdd = item.bodyTrack
            elemToAdd.removeValue(forKey: "cid")
            elemToAdd.removeValue(forKey: internal_exposure_flag)
            elemToAdd.removeValue(forKey: internal_exposure_visitor)

            ret.append(elemToAdd)
        }
        return ["cid": self.envId, "batch": ret]
    }

    func getExposureInfos() -> [FSExposedInfo]? {
        var result: [FSExposedInfo] = []

        if let aCurrentActivate = self.currentActivate as? Activate {
            if let newElem = aCurrentActivate.getExposedInfo() {
                result.append(newElem)
            }
        }
        // Do map realy nicer
        self.listActivate.forEach { item in
            if let aItem = item as? Activate {
                if let newItem = aItem.getExposedInfo() {
                    result.append(newItem)
                }
            }
        }

        // Add the activate info in the loop
        return result
    }
}
