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
        self.updateStateAndTriggerCallback(true)
        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_AUTHENTICATE.rawValue, visitor: self)
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    @objc func unauthenticate() {
        self.strategy?.getStrategy().unAuthenticateVisitor()
        self.updateStateAndTriggerCallback(false)
        // Troubleshooting xpc
        FSDataUsageTracking.sharedInstance.processTSXPC(label: CriticalPoints.VISITOR_UNAUTHENTICATE.rawValue, visitor: self)
    }

    private func updateStateAndTriggerCallback(_ isAuthenticate: Bool) {
        // Set the reason
        self.requiredFetchReason = isAuthenticate ? .VISITOR_AUTHENTICATED : .VISITOR_UNAUTHENTICATED
        // Set the fetch state to required state
        self.fetchStatus = .FETCH_REQUIRED
    }
    
    // Cpy method actually used only in bucketin mode - that expalin why we put here in this extension
    func copy() -> FSVisitor {
        let copiedVisitor = FSVisitor(
            aVisitorId: self.visitorId,
            aContext: self.context.getCurrentContext(),
            aConfigManager: self.configManager,
            aHasConsented: self.hasConsented,
            aIsAuthenticated: self.isAuthenticated,
            pOnFlagStatusChanged: self._onFlagStatusChanged,
            pOnFlagStatusFetchRequired: self._onFlagStatusFetchRequired,
            pOnFlagStatusFetched: self._onFlagStatusFetched
        )
        
        // Copy additional properties
        copiedVisitor.anonymousId = self.anonymousId
        copiedVisitor.currentFlags = self.currentFlags
        copiedVisitor.assignedVariationHistory = self.assignedVariationHistory
        copiedVisitor.requiredFetchReason = self.requiredFetchReason
        copiedVisitor.eaiVisitorScored = self.eaiVisitorScored
        copiedVisitor.emotionScoreAI = self.emotionScoreAI
        copiedVisitor.fetchStatus = self.fetchStatus
        
        // Copy strategy if needed
        if let strategy = self.strategy {
            copiedVisitor.strategy = FSStrategy(copiedVisitor)
        }
        return copiedVisitor
    }
    
    
}
