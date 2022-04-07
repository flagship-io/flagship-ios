//
//  FSTools.swift
//  FlagShip
//
//  Created by Adel on 27/01/2020.
//

import Foundation
import SystemConfiguration


let FSLengthId = 20

internal class FSTools: NSObject {

    /// Manage EnvId
    class func chekcXidEnvironment(_ xid: String) -> Bool {

        if(xid.count == FSLengthId && (xid.range(of: "[0-9a-v]{20}", options: .regularExpression) != nil)) {

            return true

        } else {

           // FSLogger.FSlog("The environmentId : \(xid) is not valide ", .Campaign)
            return false
        }
    }

    /// Manage the visitor Id

    class func manageVisitorId(_ visitorId: String?)->String {

        guard let newVisitor = visitorId else {

            if let storedId = FSGenerator.getFlagShipIdInCache() {

               // FSLogger.FSlog("The Sdk started with NIL visitorId. The SDK will handle it automatically", .Campaign)

               // FSLogger.FSlog("The Sdk will use the stored visitorId : \(storedId),  generated automatically", .Campaign)

                return storedId

             } else {

                 // Create visitor Id
                 let newId = FSGenerator.generateFlagShipId()
               // FSLogger.FSlog("The Sdk FlagShip generate a new visitorId \(newId)", .Campaign)

                // Save the visitor id
                 FSGenerator.saveFlagShipIdInCache(userId: newId)
                return newId
             }
         }
         
        return newVisitor
    }
    
    // Is Connexion Available
    class func isConnexionAvailable() -> Bool {

        let reachability = SCNetworkReachabilityCreateWithName(nil, FlagshipUniversalEndPoint)
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        return flags.contains(.reachable)
    }
}
