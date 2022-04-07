//
//  FSTargets.swift
//  FlagShip
//
//  Created by Adel on 23/01/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation

class FSTargeting: Decodable {

    let targetingGroups: [FSTargetingGroup]

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)

        do { self.targetingGroups        = try values.decode([FSTargetingGroup].self, forKey: .targetingGroups)} catch { self.targetingGroups = []}

    }

    private enum CodingKeys: String, CodingKey {

        case targetingGroups
    }

}

class FSTargetingGroup: Decodable {

    let targetings: [FSItemTarget]!

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)

        do { self.targetings        = try values.decode([FSItemTarget].self, forKey: .targetings)} catch { self.targetings = []}

    }

    private enum CodingKeys: String, CodingKey {

        case targetings
    }

}

class FSItemTarget: Decodable {

    let targetOperator: String!
    let tragetKey: String!
    let targetValue: Any?

    required public  init(from decoder: Decoder) throws {

        let values     = try decoder.container(keyedBy: CodingKeys.self)
        do { self.targetOperator               = try values.decode(String.self, forKey: .targetOperator)} catch { self.targetOperator = ""}
        do { self.tragetKey                    = try values.decode(String.self, forKey: .tragetKey)} catch { self.tragetKey = ""}

        if let val = try? values.decode(String.self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode(Bool.self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode(Int.self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode(Double.self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode([Int].self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode([String].self, forKey: .targetValue) {

            targetValue = val

        } else if let val = try? values.decode([Double].self, forKey: .targetValue) {

            targetValue = val

        } else {

            targetValue = nil
        }
    }

    private enum CodingKeys: String, CodingKey {

        case targetOperator = "operator"
        case tragetKey      = "key"
        case targetValue    = "value"
    }

}
