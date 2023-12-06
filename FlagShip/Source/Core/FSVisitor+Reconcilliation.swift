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
        self.strategy?.getStrategy().authenticateVisitor(visitorId: visitorId)

        // Update the flagSyncStatus
        self.flagSyncStatus = .AUTHENTICATED

        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_AUTHENTICATE.rawValue, visitor: self)
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    @objc func unauthenticate() {
        self.strategy?.getStrategy().unAuthenticateVisitor()
        // Update the flagSyncStatus
        self.flagSyncStatus = .UNAUTHENTICATED

        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_UNAUTHENTICATE.rawValue, visitor: self)
    }
}
