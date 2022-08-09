//
//  FSTools.swift
//  FlagShip
//
//  Created by Adel on 27/01/2020.
//

import Foundation


#if os(watchOS)
import Network
#else
import SystemConfiguration
#endif


let FSLengthId = 20

internal class FSTools: NSObject {
    
    
#if os(watchOS)
    static var available = false
    static let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
#endif
    
    
/// Check only for watchOS, will refractor checking connectevity for other platforms that use reachability
    func checkConnectevity(){
#if os(watchOS)
        FSTools.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                FSTools.available = true
            } else {
                FSTools.available =  false
            }
        }
        let queue = DispatchQueue.global(qos: .default)
        FSTools.monitor.start(queue: queue)
#endif
    }


    
    /// Manage EnvId
    class func chekcXidEnvironment(_ xid: String) -> Bool {

        if(xid.count == FSLengthId && (xid.range(of: "[0-9a-v]{20}", options: .regularExpression) != nil)) {

            return true

        } else {
            
            FlagshipLogManager.Log(level: .ALL, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.MESSAGE("The environmentId : \(xid) is not valide "))
            return false
        }
    }

    /// Manage the visitor Id

    class func manageVisitorId(_ visitorId: String?)->String {

        guard let newVisitor = visitorId else {

            if let storedId = FSGenerator.getFlagShipIdInCache() {

                return storedId

             } else {

                 /// Create visitor Id
                 let newId = FSGenerator.generateFlagShipId()
                 /// The Sdk FlagShip generate an anonymousId

                 /// Save the visitor id
                 FSGenerator.saveFlagShipIdInCache(userId: newId)
                return newId
             }
         }
         
        return newVisitor
    }
    
    // Is Connexion Available
    class func isConnexionAvailable() -> Bool {
        #if os(watchOS)
        return FSTools.available
        #else
        let reachability = SCNetworkReachabilityCreateWithName(nil, FlagshipUniversalEndPoint)
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        return flags.contains(.reachable)
        #endif
    }
}
