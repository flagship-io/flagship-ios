//
//  FSConfig.swift
//  FlagshipTests
//
//  Created by Adel on 23/07/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation



/// This class will represent
@objc public class FSConfig:NSObject{
    
    /// The timeOut, default will use the system value
    public let flagshipTimeOutRequest:TimeInterval
    
    /// Mode of Flagship uses
    public let mode:FlagshipMode
    
    
    /// Init
    public init(_ mode:FlagshipMode = .DECISION_API , _ fsTimeOutRequest:TimeInterval = 60) {
        
        /// Set Timeout
        self.flagshipTimeOutRequest = fsTimeOutRequest
        
        
        /// Set Mode
        self.mode = mode
    }
}
