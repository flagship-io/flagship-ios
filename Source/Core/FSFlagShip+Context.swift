//
//  FSFlagShip+Context.swift
//  FlagShip
//
//  Created by Adel on 08/08/2019.
//

import Foundation

extension Flagship{
    
    ///////////////////////////// Boolean /////////////////////////
    public func context(_ key:String,  _ boolean:Bool){
        
        self.context.addBoolenCtx(key, boolean)
    }
    
    
 
    
    /// Set key/value boolean to context
    /// - Parameters:
    ///   - key: name for key
    ///   - boolean: type of value
    @available(iOS, introduced: 1.0.0, deprecated: 2.0.0, message: " use updateContext(_ key:String,  _ boolean:Bool)")
    
    public func updateContext(_ key:String,  _ boolean:Bool){
        
        self.context.addBoolenCtx(key, boolean)
    }
 
    
    
    
    
    /////////////////// Double //////////////////////////////////
    
    @available(iOS, introduced: 1.0.0, deprecated: 2.0.0, message: "use updateContext(_ key:String,  _ double:Double)")
    public func context(_ key:String,  _ double:Double){
        
        self.context.addDoubleCtx(key, double)
    }
    
    
    /// Set Double to context
    /// - Parameters:
    ///   - key: name for key
    ///   - double: value
    public func updateContext(_ key:String,  _ double:Double){
        
        self.context.addDoubleCtx(key, double)
    }
    
    
 
    
    
    /////////////////////////// Text //////////////////////////////
    
    @available(iOS, introduced: 1.0.0, deprecated: 2.0.0, message: "use updateContext(_ key:String,  _ text:String)")
    public func context(_ key:String,  _ text:String){
        
        self.context.addStringCtx(key, text)
    }
    
    
    /// Set String
    /// - Parameters:
    ///   - key: name for key
    ///   - text: value
    public func updateContext(_ key:String,  _ text:String){
        
        self.context.addStringCtx(key, text)
    }
    
 
    
    
    /////////////////////////// Float /////////////////////////////

    @available(iOS, introduced: 1.0.0, deprecated: 2.0.0, message: "use updateContext(_ key:String,  _ float:Float)")
    public func context(_ key:String,  _ float:Float){
        
        self.context.addFloatCtx(key, float)
    }
    
    /// set Float to context
    /// - Parameters:
    ///   - key: name for key
    ///   - float: value
    public func updateContext(_ key:String,  _ float:Float){
        
        self.context.addFloatCtx(key, float)
    }
    
    
 
    
    
    
    /////////////////////////// Integer /////////////////////////////

    @available(iOS, introduced: 1.0.0, deprecated: 2.0.0, message: "use updateContext(_ key:String,  _ integer:Int)")
    public func context(_ key:String,  _ integer:Int){
        
        self.context.addIntCtx(key, integer)
    }
    
    
    /// Set Integer to context
    /// - Parameters:
    ///   - key: name for key
    ///   - integer: value
    public func updateContext(_ key:String,  _ integer:Int){
        
        self.context.addIntCtx(key, integer)
    }
    
    
    
    /////////////////////// Dictionary ///////////////////////////
    @objc public func updateContext(_ contextValues:Dictionary<String,Any>){
        
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        FSLogger.FSlog("Update context", .Campaign)
        
        self.context.currentContext.merge(contextValues) { (_, new) in new }
    }
    
    
    
    ////// Update the pre definded keys ////////////////////////////////
    
    
    
    /**
     Update Context with Pre defined keys
     
     @param configuredKey FSAudiences Enum for pre defined keys
     
     */
    
    public func updateContext(configuredKey:FSAudiences, value:Any){
        
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        
        /// Check the validity value
        if (!configuredKey.chekcValidity(value)){
            
            FSLogger.FSlog(" Skip updating the context with pre configured key \(configuredKey) ..... the value is not valid", .Campaign)
        }
        
        FSLogger.FSlog(" Update context with pre configured key", .Campaign)
        
        
        self.context.currentContext.updateValue(value, forKey:configuredKey.rawValue)
        
    }
    
    
    
    ///// Update context without dictionary //////////////////////
    @objc public func synchronizeModifications(/*_ contextValues:Dictionary<String,Any>,*/  completion:@escaping((FlagShipResult)->Void)){
                
        if disabledSdk{
            FSLogger.FSlog("The Sdk is disabled", .Campaign)
            return
        }
        FSLogger.FSlog("Update context", .Campaign)

        self.getCampaigns { (error) in

            if (error == nil){

                completion(.Updated)

            }else{

                completion(.NotReady)
            }
        }
        
    }
    
}
