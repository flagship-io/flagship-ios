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
@objc public class FSConfig: NSObject {

    /// The timeOut, default will use the system value
    public var flagshipTimeOutRequestApi: TimeInterval

    /// Mode of Flagship uses
    public var mode: FlagshipMode

    public var authenticated:Bool = false
    
    /// Consent boolean
    public var isConsent:Bool = true

    /// Config object that represent all customized
    /// - Parameters:
    ///   - mode: The start car run under the bukceting or decision Api mode. The default mode is DECISION_API
    ///   - apiTimeout: Time for the sdk to wait response from the getCampaign request. The default timeout is 2 seconds
    @objc public init(_ mode: FlagshipMode = .DECISION_API, timeout: TimeInterval = FS_TimeOutRequestApi, authenticated: Bool = false , isConsented:Bool = false) {

        /// Set Timeout
        self.flagshipTimeOutRequestApi = (timeout > 0) ? timeout:FS_TimeOutRequestApi

        /// Set Mode
        self.mode = mode

        if self.mode == .DECISION_API {

            /// Set Authenticated
            self.authenticated = authenticated
        } else {

            FSLogger.FSlog("authenticated is ignored in BUCKETING mode.", .Campaign)

        }
        // set the consentment 
        self.isConsent = isConsented

    }
}
