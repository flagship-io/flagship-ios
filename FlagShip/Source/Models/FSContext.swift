//
//  FSContext.swift
//  Flagship
//
//  Created by Adel on 07/09/2021.
//

class FSContext {
    private var _currentContext: [String: Any] = [:]
    
    init(_ contextValues: [String: Any]) {
        // Clean context with none valide type
        self._currentContext = contextValues.filter { $0.value is Int || $0.value is Double || $0.value is String || $0.value is Bool }
        self._currentContext = contextValues
        // Set all_users key
        _currentContext.updateValue("", forKey: ALL_USERS)
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
        _currentContext.updateValue(newValue, forKey: key)
    }

    // Load preSet Context
    func loadPreSetContext() {
        _currentContext.merge(FlagshipContextManager.getPresetContextForApp()) { _, new in new }
    }
    
    func getCurrentContext() -> [String: Any] {
        return _currentContext
    }
    
    func clearContext() {
        _currentContext.removeAll()
    }
    
    func mergeContext(_ ctxValue: [String: Any]) {
        // To do later
    }
}
