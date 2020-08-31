//
//  FSContext.swift
//  Flagship
//
//  Created by Adel on 05/08/2019.
//

import Foundation



internal class FSContext{
    
    

    
    // QueueModification
    let contextQueue = DispatchQueue(label: "com.flagship.queue.context", attributes: .concurrent)
    
    // Dictionary that represent all keys value according to context users
    private var _currentContext:Dictionary <String, Any>! // by Default the context is empty
    
    internal var currentContext:Dictionary <String, Any>!{
        
          get {
              return contextQueue.sync {
                
                  _currentContext
              }
          }
          set {
              contextQueue.async(flags: .barrier) {
                
                  self._currentContext = newValue
              }
          }
      }
    
    
    // All modification from server
    
    // QueueModification
    let modificationQueue = DispatchQueue(label: "com.flagship.queue.modifications", attributes: .concurrent)
    
    private var _currentModification:Dictionary <String, Any>
        
    internal var currentModification:Dictionary <String, Any>{
        
          get {
              return modificationQueue.sync {
                
                  _currentModification
              }
          }
          set {
              modificationQueue.async(flags: .barrier) {
                
                  self._currentModification = newValue
              }
          }
      }
    
    
    
    
    public init(){
        
        self._currentContext = Dictionary()
        
        self._currentModification = Dictionary()
    }
    
    
    
    public func updateModification(_ campaignsObject:FSCampaigns?){
        
        // Clean all curent modification before
        
        self.currentModification.removeAll()
        
        for item:FSCampaign in campaignsObject?.campaigns ?? []{
            
            if let aModifications = item.variation?.modifications {
                
                if let arrayValue = aModifications.value {
                    
                     self.currentModification.merge(arrayValue) {  (_, new) in new }
                }
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
    
    
//    /////////////////// FLoat //////////////////////////////////
//
//    public func  addFloatCtx(_ key:String, _ valueFloat:Float){
//
//        self.currentContext.updateValue(valueFloat, forKey: key)
//    }
    
    
    //////////////// Int ////////////////////////////////////////
    
    public func  addIntCtx(_ key:String, _ valueInt:Int){
        
        self.currentContext.updateValue(valueInt, forKey: key)
    }
    
    
    
    /////  Read Values ////////////
    
    // Read Boolean
    public func readBooleanFromContext(_ key:String, defaultBool:Bool)->Bool{

        if currentModification[key, default: defaultBool] is Bool {
            
            return currentModification[key, default: defaultBool] as? Bool ?? defaultBool
        }
        
        return defaultBool
    }
    
    
    //  Read String
    public func readStringFromContext(_ key:String, defaultString:String)->String{
        
        if currentModification[key, default: defaultString] is String{
            
            return currentModification[key, default: defaultString] as? String ?? defaultString
        }
        
        return defaultString
    }
    
    
    /// Read Double
    public func readDoubleFromContext(_ key:String, defaultDouble:Double)->Double{
        
        if currentModification[key, default: defaultDouble] is Double{
            
             return currentModification[key, default: defaultDouble] as? Double ?? defaultDouble
        }
        
        return defaultDouble
    }
    
    
    /// Float
    public func readFloatFromContext(_ key:String, defaultFloat:Float)->Float{
        
        if currentModification[key, default: defaultFloat] is Float{
            
            return currentModification[key, default: defaultFloat] as? Float ?? defaultFloat
        }
        
        return defaultFloat
    }
    
    // Int
    public func readIntFromContext(_ key:String, defaultInt:Int)->Int{
        
        if currentModification[key, default: defaultInt] is Int{
            
            return currentModification[key, default: defaultInt] as? Int ?? defaultInt
        }
        return defaultInt
    }
    
    
    
    /// Tempo & Need tests

    public func readJsonObjectFromContext(_ key:String, defaultDico:[String:Any])->[String:Any]{
        
        if currentModification[key] is [String:Any]{
            
            return currentModification[key, default:defaultDico] as! [String:Any]
            
        }else{
            
            return defaultDico
        }
    }
    
    
    public func readArrayFromContext(_ key:String, defaultArray:[Any])->[Any]{
        
        if currentModification[key] is [Any]{
            
            return currentModification[key, default:defaultArray] as! [Any]
        }else{
            
            return defaultArray
        }
    }
    
    
    
    ///
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
