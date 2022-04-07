//
//  FSLogManager.swift
//  Flagship
//
//  Created by Adel on 13/10/2021.
//

import Foundation

@objc public enum FSLevel:Int{
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
}

public class FSLogManager {
    
    
    init(){
        
        _level = .ALL
    }
    
    internal var _level:FSLevel
    
    internal var level:FSLevel{
        
        get{
            return _level
        }
        set{
            _level = newValue
        }
    }
    /**
      * Called when the SDK produce a log.
      * @param level log level.
      * @param tag location where the log come from.
      * @param message log message.
      */
    func onLog(level:FSLevel, tag:String, message:String){
        
    }
    
    func getLevel()->FSLevel{
        return _level
    }
}
    
