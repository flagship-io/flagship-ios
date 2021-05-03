//
//  Flagship+Reconcilliation.swift
//  Flagship
//
//  Created by Adel on 12/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation


extension Flagship{
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - visitorId: <#newVisitorId description#>
    ///   - visitorContext: <#context description#>
    ///   - sync: <#onSynchronized description#>
   @objc public func authenticateVisitor(visitorId:String, visitorContext:[String:Any]? = nil, sync:((FlagshipResult)->Void)? = nil){
        
        if (sdkModeRunning == .BUCKETING){
            
            FSLogger.FSlog("authenticateVisitor() is ignored in BUCKETING mode.", .Campaign)
            return
        }
        
        /// Update the visitor an anonymous id 
        if self.anonymousId == nil{
            
            self.anonymousId = self.visitorId
        }
        
        self.visitorId = visitorId
        
        ///set the new context if provided here
        /// if the context is nill ==> will no effect or erase the current context
        self.context.setNewContext(visitorContext)
        
        if let aSync = sync {
            
            self.synchronizeModifications { (result) in
                
                aSync(result)
            }
        }
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - context: <#context description#>
    ///   - onSynchronized: <#onSynchronized description#>
    @objc public func unAuthenticateVisitor( visitorContext:[String:Any]? = nil, sync:((FlagshipResult)->Void)? = nil){
        
        if (sdkModeRunning == .BUCKETING){
            
            FSLogger.FSlog("unAuthenticateVisitor() is ignored in BUCKETING mode.", .Campaign)

            return
        }
        
        self.visitorId = self.anonymousId
        
        self.anonymousId = nil
        
        ///set the new context if provided here
        /// if the context is nill ==> will no effect or erase the current context
        self.context.setNewContext(visitorContext)
        
        if let aSync = sync {
            
            self.synchronizeModifications { (result) in
                
                aSync(result)
            }
        }
    }
    
    
//    /// Get the current context
//    /// - Returns: Dictionary of key value [String:Any]
//    @objc public func getVisitorContext()->Dictionary<String, Any>{
//        
//        self.context.currentContext
//    }
}
