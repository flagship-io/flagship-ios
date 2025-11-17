//
//  FSSegment.swift
//  Flagship
//
//  Created by Adel Ferguen on 16/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class FSSegment: FSTracking {
    // Init with an empty context
    var context: [String: Any] = [:]

    // Init Segment
    public init(_ pContext: [String: Any]) {
        super.init()
        self.type = .SEGMENT
        self.dataSource = "APP"
        self.context = pContext
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { try super.init(from: decoder) }
        // Context
        do { self.context = try values.decode([String: Any].self, forKey: .context) } catch { self.context = [:] }
        self.type = .SEGMENT
    }

    private enum CodingKeys: String, CodingKey {
        case context = "s"
    }

    override var bodyTrack: [String: Any] {
        var contextParam = [String: Any]()
        // Set type
        contextParam.updateValue(self.type.typeString, forKey: "t")
        // Set Client Id
        contextParam.updateValue(self.envId ?? "", forKey: "cid")
        // Set Data source
        contextParam.updateValue(self.dataSource, forKey: "ds")
        // Set the context
        contextParam.updateValue(self.context.compactMapValues { "\($0)" }, forKey: "s")
        // Merge the visitorId and AnonymousId
        contextParam.merge(self.createTupleId()) { _, new in new }
        /// Add qt entries
        /// Time difference between when the hit was created and when it was sent
        let qt = Date().timeIntervalSince1970 - self.createdAt
        contextParam.updateValue(qt.rounded(), forKey: "qt")
        return contextParam
    }
}
