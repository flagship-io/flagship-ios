//
//  FSVisitorBuilder.swift
//  Flagship
//
//  Created by Adel on 09/12/2021.
//

import Foundation

public typealias onFlagStatusChanged = ((_ newStatus: FSFlagsStatus, _ reason: FSFetchReasons)-> Void)?

/// Visitor builder
@objc public class FSVisitorBuilder: NSObject {
    /// Visitor
    public private(set) var _visitorId: String
    /// Has consented
    public private(set) var _hasConsented: Bool = true
    /// Context
    public private(set) var _context: [String: Any] = [:]
    /// Is authenticated
    public private(set) var _isAuthenticated: Bool = false
    /// instance
    private var _instanceType: Instance = .SHARED_INSTANCE
    
    // Callbak for status
    private var _onFlagStatusChanged: onFlagStatusChanged = nil
    
    public init(_ visitorId: String, instanceType: Instance = .SHARED_INSTANCE) {
        if visitorId.isEmpty {
            _visitorId = FSGenerator.generateFlagShipId()
            FlagshipLogManager.Log(level: .WARNING, tag: .VISITOR, messageToDisplay: FSLogMessage.ID_NULL_OR_EMPTY)
            
        } else {
            _visitorId = visitorId
        }
        
        _instanceType = instanceType
    }
    
    @objc public func hasConsented(hasConsented: Bool)->FSVisitorBuilder {
        _hasConsented = hasConsented
        return self
    }
    
    @objc public func withContext(context: [String: Any])->FSVisitorBuilder {
        _context = context
        return self
    }
    
    @objc public func isAuthenticated(_ autenticated: Bool)->FSVisitorBuilder {
        _isAuthenticated = autenticated
        return self
    }
    
    public func withFlagStatus(_ pCallback: onFlagStatusChanged)->FSVisitorBuilder {
        _onFlagStatusChanged = pCallback
        return self
    }
    
    @objc public func build()->FSVisitor {
        let newVisitor = Flagship.sharedInstance.newVisitor(_visitorId, context: _context, hasConsented: _hasConsented, isAuthenticated: _isAuthenticated, pOnFlagStatusChanged: _onFlagStatusChanged)
        
        if _instanceType == .SHARED_INSTANCE {
            /// Set this visitor as shared instance
            Flagship.sharedInstance.setSharedVisitor(newVisitor)
        }
        return newVisitor
    }
}
