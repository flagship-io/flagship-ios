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
    
    // This boolean is used to mark is the context had changed
    private var _needToUpload:Bool = false
    var needToUpload:Bool {
        get {
            return queueCtx.sync {
                _needToUpload
            }
        }
        set {
            queueCtx.async(flags: .barrier) {
                self._needToUpload = newValue
            }
        }
    }
    
    init(_ contextValues: [String: Any]) {
        // Clean context with none valide type
        self.currentContext = contextValues.filter { $0.value is Int || $0.value is Double || $0.value is String || $0.value is Bool }
        self.currentContext = contextValues
        // Set all_users key
        currentContext.updateValue("", forKey: ALL_USERS)
        _needToUpload = true
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
    
    // Check if the context changed.
    internal func isContextUnchanged(_ otherCtx: [String: Any]) -> Bool {
        if otherCtx.count != self.currentContext.count {
             return false
         }
         for (otherKey, otherValue) in otherCtx {
             // Check if the second dictionary has the same key
             guard let currentValue = self.currentContext[otherKey] else {
                 return false
             }
             // Compare values type by type
             if let v1 = otherValue as? Int, let v2 = currentValue as? Int {
                 if v1 != v2 {
                     return false
                 }
             }
             else if let v1 = otherValue as? Bool, let v2 = currentValue as? Bool {
                 if v1 != v2 {
                     return false
                 }
             }
             else if let v1 = otherValue as? Float, let v2 = currentValue as? Float {
                 if v1 != v2 {
                     return false
                 }
             }
             else if let v1 = otherValue as? Double, let v2 = currentValue as? Double {
                 if v1 != v2 {
                     return false
                 }
             }
             else if let v1 = otherValue as? String, let v2 = currentValue as? String {
                 if v1 != v2 {
                     return false
                 }
             }  else {
                 // Unhandled types return false
                return false
             }
         }
         return true
     }
  
    
}
