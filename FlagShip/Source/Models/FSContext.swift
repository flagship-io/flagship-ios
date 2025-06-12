//
//  FSContext.swift
//  Flagship
//
//  Created by Adel on 07/09/2021.
//

import Foundation

class FSContext {
    private let queueCtx = DispatchQueue(label: "ctx.queue", attributes: .concurrent)
    
    public var currentContext: [String: Any] {
        get {
            return queueCtx.sync {
                _currentContext
            }
        }
        set {
            queueCtx.async(flags: .barrier) {
                self._currentContext = newValue
            }
        }
    }
    
    //
    private var _currentContext: [String: Any] = [:]
    
    init(_ contextValues: [String: Any], visitorId: String) {
        // Clean context with none valide type
        self.currentContext = contextValues.filter { $0.value is Int || $0.value is Double || $0.value is String || $0.value is Bool }
        self.currentContext = contextValues
        // Set all_users key
        currentContext.updateValue("", forKey: ALL_USERS)
        // Set fs_users
        currentContext.updateValue(visitorId, forKey: FS_USERS)
    }
    
    public func updateContext(_ newValues: [String: Any]) {
        FlagshipLogManager.Log(level: .INFO, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_CONTEXT)
        for key in newValues.keys {
            if let val = newValues[key] {
                switch val {
                case is Int, is Double, is String, is Bool:
                    updateContext(key, val)
                    
                default:
                    FlagshipLogManager.Log(level: .ERROR, tag: .UPDATE_CONTEXT, messageToDisplay: FSLogMessage.UPDATE_CONTEXT_FAILED(key))
                }
            }
        }
    }
    
    public func updateContext(_ key: String, _ newValue: Any) {
        currentContext.updateValue(newValue, forKey: key)
    }

    // Load preSet Context
    func loadPreSetContext() {
        currentContext.merge(FlagshipContextManager.getPresetContextForApp()) { _, new in new }
    }
    
    func getCurrentContext() -> [String: Any] {
        return currentContext
    }
    
    func clearContext() {
        currentContext.removeAll()
    }
    
    func mergeContext(_ ctxValue: [String: Any]) {
        // To do later
    }
}
