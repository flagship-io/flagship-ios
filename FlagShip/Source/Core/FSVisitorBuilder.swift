//
//  FSVisitorBuilder.swift
//  Flagship
//
//  Created by Adel on 09/12/2021.
//

import Foundation

// Called every time the Flag status changes.
public typealias OnFlagStatusChanged = ((_ newStatus: FSFlagStatus)-> Void)?
// Called every time when the FlagStatus is equals to FETCH_REQUIRED
public typealias OnFlagStatusFetchRequired = ((_ reason: FetchFlagsRequiredStatusReason)->Void)?
// Called every time when the FlagStatus is equals to FETCHED.
public typealias OnFlagStatusFetched = (()->Void)?


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
    
    // Called every time the Flag status changes.
    private var _onFlagStatusChanged: OnFlagStatusChanged = nil
    // Called every time when the FlagStatus is equals to FETCH_REQUIRED
    private var _onFlagStatusFetchRequired: OnFlagStatusFetchRequired = nil
    // Called every time when the FlagStatus is equals to FETCHED.
    private var _onFlagStatusFetched: OnFlagStatusFetched = nil
    
    
    public init(_ visitorId: String, _ hasConsented: Bool, instanceType: Instance = .SHARED_INSTANCE) {
        if visitorId.isEmpty {
            _visitorId = FSGenerator.generateFlagShipId()
            FlagshipLogManager.Log(level: .WARNING, tag: .VISITOR, messageToDisplay: FSLogMessage.ID_NULL_OR_EMPTY)
            
        } else {
            _visitorId = visitorId
        }
        
        _instanceType = instanceType
        _hasConsented = hasConsented
    }
    
    @objc public func withContext(context: [String: Any])->FSVisitorBuilder {
        _context = context
        return self
    }
    
    @objc public func isAuthenticated(_ autenticated: Bool)->FSVisitorBuilder {
        _isAuthenticated = autenticated
        return self
    }
    
    // OnFlagStatusChanged
    public func withOnFlagStatusChanged(_ onFlagStatusChanged: OnFlagStatusChanged)->FSVisitorBuilder {
        _onFlagStatusChanged = onFlagStatusChanged
        return self
    }
    // OnFlagStatusFetchRequired
    public func withOnFlagStatusFetchRequired(_ onFlagStatusFetchRequired: OnFlagStatusFetchRequired)->FSVisitorBuilder {
        _onFlagStatusFetchRequired = onFlagStatusFetchRequired
        return self
    }
    // withOnFlagStatusFetched
    public func withOnFlagStatusFetched (_ onFlagStatusFetched: OnFlagStatusFetched)->FSVisitorBuilder {
        _onFlagStatusFetched = onFlagStatusFetched
        return self
    }
    
    
    @objc public func build()->FSVisitor {
        let newVisitor = Flagship.sharedInstance.newVisitor(_visitorId, context: _context, hasConsented: _hasConsented, isAuthenticated: _isAuthenticated, pOnFlagStatusChanged: _onFlagStatusChanged, pOnFlagStatusFetchRequired: _onFlagStatusFetchRequired, pOnFlagStatusFetched: _onFlagStatusFetched
        
        )
        
        if _instanceType == .SHARED_INSTANCE {
            /// Set this visitor as shared instance
            Flagship.sharedInstance.setSharedVisitor(newVisitor)
        }
        return newVisitor
    }
}
