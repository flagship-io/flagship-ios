//
//  FSVisitor+Reconcilliation.swift
//  Flagship
//
//  Created by Adel on 14/12/2021.
//

import Foundation

extension FSVisitor {
    
    /// Use authenticate methode to go from Logged out  session to logged in session
    /// - Parameters:
    ///   - visitorId: newVisitorId to atuthenticate
   @objc public func authenticate(visitorId: String) {
       
       self.strategy?.getStrategy().authenticateVisitor(visitorId: visitorId)
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    @objc public func unauthenticate() {
        
        self.strategy?.getStrategy().unAuthenticateVisitor()
    }
}

