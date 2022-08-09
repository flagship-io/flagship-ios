//
//  FSVisitor+Reconcilliation.swift
//  Flagship
//
//  Created by Adel on 14/12/2021.
//

import Foundation

extension FSVisitor {
    
    ///   Use authenticate methode to go from Logged-out session to logged-in session
    ///
    /// - Parameters:
    ///      - visitorId: newVisitorId to authenticate
    /// - Important: After using this method, you should use Flagship.fetchFlags method to update the visitor informations
    /// - Requires: Make sure that the experience continuity option is enabled on the flagship platform before using this method
   @objc public func authenticate(visitorId: String) {
       
       self.strategy?.getStrategy().authenticateVisitor(visitorId: visitorId)
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    @objc public func unauthenticate() {
        
        self.strategy?.getStrategy().unAuthenticateVisitor()
    }
}
