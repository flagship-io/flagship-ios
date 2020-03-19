//
//  FSContext.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation



internal class FSContext{
    
    
    // Dictionary that represent all keys value according to context users
    internal var currentContext:Dictionary <String, Any>! // by Default the context is empty
    
    // All modification from server 
    private var currentModification:Dictionary <String, Any>
    
    
    public init(){
        
        self.currentContext = Dictionary()
        
        self.currentModification = Dictionary()
    }
    
    
    
    public func updateModification(_ campaignsObject:FSCampaigns?){
        
        // Clean all curent modification before
        
        self.currentModification.removeAll()
        
        for item:FSCampaign in campaignsObject?.campaigns ?? []{
            
            if (item.variation?.modifications != nil){
                
                  self.currentModification.merge((item.variation?.modifications!.value)!) {  (_, new) in new }
            }
        }
    }
    
    
    ////////////////// BOOL ///////////////////////////////
    // Add Bool Key / value
    public func  addBoolenCtx(_ key:String, _ bool:Bool){
        
        self.currentContext.updateValue(bool, forKey: key)
    }

    
    ////////////////// STRING ///////////////////////////////
    
    // Add String Key / value
    public func  addStringCtx(_ key:String, _ valueString:String){
        
        self.currentContext.updateValue(valueString, forKey: key)
    }
 
    ////////////////// Double ///////////////////////////////
    
    // Add Bool Key / value
    public func  addDoubleCtx(_ key:String, _ valueDouble:Double){
        
        self.currentContext.updateValue(valueDouble, forKey: key)
    }
    
    
    /////////////////// FLoat //////////////////////////////////
    
    public func  addFloatCtx(_ key:String, _ valueFloat:Float){
        
        self.currentContext.updateValue(valueFloat, forKey: key)
    }
    
    
    //////////////// Int ////////////////////////////////////////
    
    public func  addIntCtx(_ key:String, _ valueInt:Int){
        
        self.currentContext.updateValue(valueInt, forKey: key)
    }
    
    
    
    /////  Read Values ////////////
    
    // Read Boolean
    public func readBooleanFromContext(_ key:String, defaultBool:Bool)->Bool{

        if currentModification[key, default: defaultBool] is Bool {
            
            return currentModification[key, default: defaultBool] as! Bool
        }
        
        return defaultBool
    }
    
    
    //  Read String
    public func readStringFromContext(_ key:String, defaultString:String)->String{
        
        if currentModification[key, default: defaultString] is String{
            
            return currentModification[key, default: defaultString] as! String
        }
        
        return defaultString
    }
    
    
    /// Read Double
    public func readDoubleFromContext(_ key:String, defaultDouble:Double)->Double{
        
        if currentModification[key, default: defaultDouble] is Double{
            
             return currentModification[key, default: defaultDouble] as! Double
        }
        
        return defaultDouble
    }
    
    
    /// Float
    public func readFloatFromContext(_ key:String, defaultFloat:Float)->Float{
        
        if currentModification[key, default: defaultFloat] is Float{
            
            return currentModification[key, default: defaultFloat] as! Float
        }
        
        return defaultFloat
    }
    
    // Int
    public func readIntFromContext(_ key:String, defaultInt:Int)->Int{
        
        if currentModification[key, default: defaultInt] is Int{
            
            return currentModification[key, default: defaultInt] as! Int
        }
        return defaultInt
    }
    
    //////////////// Remove   &   Clean   ///////////////////////
   
    public func  removeKeyFromContext(_ key:String){
        
        self.currentContext.removeValue(forKey: key)
        
    }
    
    // Remove All values from context
    
    public func cleanContext(){
        
        self.currentContext.removeAll()
    }
    
    
    // Remove Modification
    
    public func cleanModification(){
        
        self.currentModification.removeAll()
    }
}
