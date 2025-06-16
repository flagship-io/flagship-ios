//
//  FSVisitor+Reconcilliation.swift
//  Flagship
//
//  Created by Adel on 14/12/2021.
//

import Foundation

public extension FSVisitor {
    ///   Use authenticate methode to go from Logged-out session to logged-in session
    ///
    /// - Parameters:
    ///      - visitorId: newVisitorId to authenticate
    /// - Important: After using this method, you should use Flagship.fetchFlags method to update the visitor informations
    /// - Requires: Make sure that the experience continuity option is enabled on the flagship platform before using this method
    @objc func authenticate(visitorId: String) {
        if configManager.flagshipConfig.mode != .DECISION_API {
            FlagshipLogManager.Log(level: .ALL, tag: .AUTHENTICATE, messageToDisplay: FSLogMessage.IGNORE_AUTHENTICATE)
            return
        }
        self.strategy?.getStrategy().authenticateVisitor(visitorId: visitorId)
        self.updateStateAndTriggerCallback(true)
        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_AUTHENTICATE.rawValue, visitor: self)
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    @objc func unauthenticate() {
        if configManager.flagshipConfig.mode != .DECISION_API {
            FlagshipLogManager.Log(level: .ALL, tag: .UNAUTHENTICATE, messageToDisplay: FSLogMessage.IGNORE_AUTHENTICATE)
            return
        }
        self.strategy?.getStrategy().unAuthenticateVisitor()
        self.updateStateAndTriggerCallback(false)
        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_UNAUTHENTICATE.rawValue, visitor: self)
    }

    private func updateStateAndTriggerCallback(_ isAuthenticate: Bool) {
        // Update flagSyncStatus
        self.flagSyncStatus = isAuthenticate ? .AUTHENTICATED : .UNAUTHENTICATED

        // Set the reason
        self.requiredFetchReason = isAuthenticate ? .AUTHENTICATE : .UNAUTHENTICATE
        // Set the fetch state to required state
        self.fetchStatus = .FETCH_REQUIRED
    }
}
