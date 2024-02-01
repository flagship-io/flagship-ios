//
//  FSLogManager.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

@objc public enum FSLevel: Int {
    /**
     * NONE = 0: Logging will be disabled.
     */
    case NONE
    /**
     * EXCEPTIONS = 1: Only caught exception will be logged.
     */
    case EXCEPTIONS
    /**
     * ERROR = 2: Only errors and above will be logged.
     */
    case ERROR
    /**
     * WARNING = 3: Only warnings and above will be logged.
     */
    case WARNING
    /**
     * DEBUG = 4: Only debug logs and above will be logged.
     */
    case DEBUG
    /**
     * INFO = 5: Only info logs and above will be logged.
     */
    case INFO
    /**
     * ALL = 6: All logs will be logged.
     */
    case ALL
    
    var name: String {
        var ret = ""
        switch self {
        case .NONE:
            ret = "NONE"
        case .EXCEPTIONS:
            ret = "EXCEPTIONS"
        case .ERROR:
            ret = "ERROR"
        case .WARNING:
            ret = "WARNING"
        case .DEBUG:
            ret = "DEBUG"
        case .INFO:
            ret = "INFO"
        case .ALL:
            ret = "ALL"
        }
        return ret
    }
}

public class FSLogManager {
    init() {
        _level = .ALL
    }
    
    var _level: FSLevel
    
    var level: FSLevel {
        get {
            return _level
        }
        set {
            _level = newValue
        }
    }

    /**
     * Called when the SDK produce a log.
     * @param level log level.
     * @param tag location where the log come from.
     * @param message log message.
     */
    func onLog(level: FSLevel, tag: String, message: String) {}
    
    func getLevel() -> FSLevel {
        return _level
    }
}
    
