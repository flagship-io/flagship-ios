//
//  FSTargeting+semVer.swift
//  Flagship
//
//  Created by Adel Ferguen on 04/07/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

extension FSTargetingManager {
//    func checkSemver(_ opType: FSoperator, _ currentValue: Any, _ audienceValue: Any) -> Bool {
//        // Result checking
//        var ret = false
//        // Before treating the semantic version, need to validate before the semantic format
//        guard let currentSemver = Semver(currentValue as? String ?? "") else {
//            FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("\(currentValue) is not a valide semantic version format, ==> The \(opType.rawValue) condistion is not satisfied ❌ "))
//            return false
//        }
//
//        guard let audienceSemver = Semver(audienceValue as? String ?? "") else {
//            FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("\(audienceValue) is not a valide semantic version format, ==> The \(opType.rawValue) condistion is not satisfied ❌ "))
//            return false
//        }
//
//        switch opType {
//        case .SEMVER_EQUALS:
//            ret = currentSemver == audienceSemver
//        case .SEMVER_NOT_EQUALS:
//            ret = currentSemver != audienceSemver
//        case .SEMVER_GREATER_THAN:
//            ret = currentSemver > audienceSemver
//        case .SEMVER_LOWER_THAN:
//            ret = currentSemver < audienceSemver
//        case .SEMVER_GREATER_THAN_OR_EQUALS:
//            ret = currentSemver >= audienceSemver
//        case .SEMVER_LOWER_THAN_OR_EQUALS:
//            ret = currentSemver <= audienceSemver
//        default:
//            break
//        }
//        FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("The semantic condition: \(currentSemver.description) \(opType.rawValue) \(audienceSemver.description) \(ret ? "is satisfied 👍" : "is not satisfied ❌")"))
//
//        return ret
//    }

    func checkSemver(_ opType: FSoperator, _ currentValue: String, _ audienceValue: String) -> Bool {
        // Result checking
        var ret = false
        // Before treating the semantic version, need to validate before the semantic format
        guard let currentSemver = Semver(currentValue) else {
            FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("\(currentValue) is not a valide semantic version format, ==> The \(opType.rawValue) condistion is not satisfied ❌ "))
            return false
        }

        guard let audienceSemver = Semver(audienceValue) else {
            FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("\(audienceValue) is not a valide semantic version format, ==> The \(opType.rawValue) condistion is not satisfied ❌ "))
            return false
        }

        switch opType {
        case .SEMVER_EQUALS:
            ret = currentSemver == audienceSemver
        case .SEMVER_NOT_EQUALS:
            ret = currentSemver != audienceSemver
        case .SEMVER_GREATER_THAN:
            ret = currentSemver > audienceSemver
        case .SEMVER_LOWER_THAN:
            ret = currentSemver < audienceSemver
        case .SEMVER_GREATER_THAN_OR_EQUALS:
            ret = currentSemver >= audienceSemver
        case .SEMVER_LOWER_THAN_OR_EQUALS:
            ret = currentSemver <= audienceSemver
        default:
            break
        }
        FlagshipLogManager.Log(level: .ALL, tag: .TARGETING, messageToDisplay: FSLogMessage.MESSAGE("The semantic condition: \(currentSemver.description) \(opType.rawValue) \(audienceSemver.description) \(ret ? "is satisfied 👍" : "is not satisfied ❌")"))

        return ret
    }
}
