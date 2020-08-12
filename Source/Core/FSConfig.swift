//
//  FSConfig.swift
//  FlagshipTests
//
//  Created by Adel on 23/07/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation


/// By the default the timeout will be 2 seconds
public let FS_TimeOutRequestApi = 2.0

/// This class will represent
@objc public class FSConfig:NSObject{
    
    /// The timeOut, default will use the system value
    public let flagshipTimeOutRequestApi:TimeInterval
    
    /// Mode of Flagship uses
    public let mode:FlagshipMode
    
    
    
    /// Config object that represent all customized
    /// - Parameters:
    ///   - mode: The start car run under the bukceting or decision Api mode. The default mode is DECISION_API
    ///   - apiTimeout: Time for the sdk to wait response from the getCampaign request. The default timeout is 2 seconds
    public init(_ mode:FlagshipMode = .DECISION_API , apiTimeout:TimeInterval = FS_TimeOutRequestApi) {
        
        /// Set Timeout
        self.flagshipTimeOutRequestApi = apiTimeout
        
        /// Set Mode
        self.mode = mode
    }
}
