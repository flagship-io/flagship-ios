//
//  Flagship+Reconcilliation.swift
//  Flagship
//
//  Created by Adel on 12/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation

extension Flagship {

    /// Use authenticate methode to go from Logged out  session to logged in session
    /// - Parameters:
    ///   - visitorId: newVisitorId to atuthenticate
    ///   - visitorContext: context for the user
    ///   - sync: callback will be invoked when the synchronize complete, by default the callBack is nil
   @objc public func authenticateVisitor(visitorId: String, visitorContext: [String: Any]? = nil, sync: ((FlagshipResult) -> Void)? = nil) {

        if sdkModeRunning == .BUCKETING {

            FSLogger.FSlog("authenticateVisitor() is ignored in BUCKETING mode.", .Campaign)
            return
        }

        /// Update the visitor an anonymous id 
        if self.anonymousId == nil {

            self.anonymousId = self.visitorId
        }

        self.visitorId = visitorId

        /// set the new context if provided here
        /// if the context is nill ==> will no effect or erase the current context
        self.context.setNewContext(visitorContext)

        if let aSync = sync {

            self.synchronizeModifications { (result) in

                aSync(result)
            }
        }
    }

    /// Use authenticate methode to go from Logged in  session to logged out session
    /// - Parameters:
    ///   - context: input a new context if needed when log-out
    ///   - onSynchronized: Callback is called when the operation complete , by default is nil
    @objc public func unAuthenticateVisitor( visitorContext: [String: Any]? = nil, sync: ((FlagshipResult) -> Void)? = nil) {

        if sdkModeRunning == .BUCKETING {

            FSLogger.FSlog("unAuthenticateVisitor() is ignored in BUCKETING mode.", .Campaign)

            return
        }

        self.visitorId = self.anonymousId

        self.anonymousId = nil

        /// set the new context if provided here
        /// if the context is nill ==> will no effect or erase the current context
        self.context.setNewContext(visitorContext)

        if let aSync = sync {

            self.synchronizeModifications { (result) in

                aSync(result)
            }
        }
    }
}
