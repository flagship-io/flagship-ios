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
    
    
    /// Init
    public init(_ mode:FlagshipMode = .DECISION_API , fsTimeOutRequest:TimeInterval = FS_TimeOutRequestApi) {
        
        /// Set Timeout
        self.flagshipTimeOutRequestApi = fsTimeOutRequest
        
        /// Set Mode
        self.mode = mode
    }
}
