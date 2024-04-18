//
//  FSConfig.swift
//  Flagship
//
//  Created by Adel on 31/08/2021.
//

import Foundation

public let FSTimeoutRequestApi = 2.0

public let FSPollingTime = 60.0 // seconds

public enum FSMode: Int {
    case DECISION_API = 1
    case BUCKETING = 2
}

public typealias OnVisitorExposed = ((_ visitorExposed: FSVisitorExposed, _ fromFlag: FSExposedFlag)-> Void)?

public typealias StatusListener = (_ newStatus: FSSdkStatus)->Void

@objc public class FlagshipConfig: NSObject, FSPollingScriptDelegate {
    func onGetScript(_ newBucketing: FSBucket?, _ error: FlagshipError?) {}
    
    let fsQueue = DispatchQueue(label: "com.flagshipConfig.queue", attributes: .concurrent)

    var mode: FSMode = .DECISION_API
    var timeout: TimeInterval
    var logLevel: FSLevel = .ALL
    var pollingTime: TimeInterval = FSPollingTime
    var onSdkStatusChanged: ((_ newStatus: FSSdkStatus)->Void)? = nil
    var trackingConfig: FSTrackingManagerConfig
    var onVisitorExposed: OnVisitorExposed = nil
    
    /// Cache Manager
    var cacheManager: FSCacheManager
    
    // Data Usage
    var disableDeveloperUsageTracking: Bool

    init(_ mode: FSMode = .DECISION_API,
         _ timeOut: TimeInterval = FSTimeoutRequestApi,
         _ logLevel: FSLevel = .ALL,
         pollingTime: TimeInterval = FSPollingTime,
         cacheManager: FSCacheManager,
         _ onStatusChanged: ((_ newStatus: FSSdkStatus)->Void)? = nil,
         _ trackingConfig: FSTrackingManagerConfig, _ onVisitorExposed: OnVisitorExposed = nil, _ disableDeveloperUsageTracking: Bool = true)
    {
        self.mode = mode
        self.timeout = timeOut
        self.logLevel = logLevel
        self.pollingTime = pollingTime
        self.cacheManager = cacheManager
        self.onSdkStatusChanged = onStatusChanged
        self.trackingConfig = trackingConfig
        self.onVisitorExposed = onVisitorExposed
        self.disableDeveloperUsageTracking = disableDeveloperUsageTracking
    }
}

@objc public class FSConfigBuilder: NSObject {
    override public init() {
        self._cacheManager = FSCacheManager(FSDefaultCacheVisitor(), FSDefaultCacheHit())
        // Init with a default value
        self._trackingConfig = FSTrackingManagerConfig()
    }
    
    /// _ Mode
    public private(set) var _mode: FSMode = .DECISION_API
    
    /// _timeOut
    public private(set) var _timeOut: TimeInterval = FSTimeoutRequestApi
    
    /// _logLevel
    public private(set) var _logLevel: FSLevel = .ALL
    
    /// _pollingTime
    public private(set) var _pollingTime: TimeInterval = FSPollingTime
    
    /// Cache manager
    public private(set) var _cacheManager: FSCacheManager
    
    /// Status listener
    public private(set) var _onStatusListener: ((_ newStatus: FSSdkStatus)->Void)? = nil
    
    /// Tracking Config
    public private(set) var _trackingConfig: FSTrackingManagerConfig
    
    /// On visitor Exposure
    public private(set) var _onVisitorExposure: OnVisitorExposed = nil
    
    /// Developer usage tracking
    public private(set) var _disableDeveloperUsageTracking: Bool = false

    /// _ With
    
    /// Decision Mode
    @objc public func DecisionApi()->FSConfigBuilder {
        _mode = .DECISION_API
        return self
    }
    
    /// Bucketing Mode
    @objc public func Bucketing()->FSConfigBuilder {
        _mode = .BUCKETING
        return self
    }
    
    /// TimeOut
    @objc public func withTimeout(_ timeout: TimeInterval)->FSConfigBuilder {
        /// The input is proposed by the MS, then we devide by 1000 to get seconds
        _timeOut = timeout / 1000
        return self
    }
    
    /// LogLevel
    @objc public func withLogLevel(_ logLevel: FSLevel)->FSConfigBuilder {
        _logLevel = logLevel
        return self
    }
    
    /// Polling Time
    @objc public func withBucketingPollingIntervals(_ pollingTime: TimeInterval)->FSConfigBuilder {
        _pollingTime = pollingTime
        return self
    }
    
    /// Cache Manager
    @objc public func withCacheManager(_ customCacheManager: FSCacheManager)->FSConfigBuilder {
        _cacheManager = customCacheManager
        return self
    }
    
    /// listener status
    @objc public func withStatusListener(_ statusListener: @escaping (_ newStatus: FSSdkStatus)->Void)->FSConfigBuilder {
        _onStatusListener = statusListener
        return self
    }
    
    /// Tracking Configuration
    @objc public func withTrackingManagerConfig(_ trackingMgrConfig: FSTrackingManagerConfig)->FSConfigBuilder {
        _trackingConfig = trackingMgrConfig
        return self
    }
    
    /// Visitor Exposed
    @objc public func withOnVisitorExposed(_ onVisitorExposed: OnVisitorExposed)->FSConfigBuilder {
        _onVisitorExposure = onVisitorExposed
        return self
    }
    
    /// With disableDeveloperUsageTracking
    
    @objc public func withDisableDeveloperUsageTracking(_ disableDeveloperUsageTracking: Bool)->FSConfigBuilder {
        _disableDeveloperUsageTracking = disableDeveloperUsageTracking
        return self
    }
    
    @objc public func build()->FlagshipConfig {
        return FlagshipConfig(_mode, _timeOut, _logLevel, pollingTime: _pollingTime, cacheManager: _cacheManager, _onStatusListener, _trackingConfig, _onVisitorExposure, _disableDeveloperUsageTracking)
    }
}
