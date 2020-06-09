//
//  FSFlagShip+Context.swift
//  FlagShip
//
//  Created by Adel on 08/08/2019.
//

import Foundation

extension ABFlagShip{
    
    
    // Update boolean context
    public func context(_ key:String,  _ boolean:Bool){
        
        self.context.addBoolenCtx(key, boolean)
    }
    
    // Update Double Context
    public func context(_ key:String,  _ double:Double){
        
        self.context.addDoubleCtx(key, double)
    }
    
    // Update Context Text
    public func context(_ key:String,  _ text:String){
        
        self.context.addStringCtx(key, text)
    }
    
    
    // Update Float
    // Update Context Text
    public func context(_ key:String,  _ float:Float){
        
        self.context.addFloatCtx(key, float)
    }
    
    // Update Int context
    public func context(_ key:String,  _ integer:Int){
        
        self.context.addIntCtx(key, integer)
    }
    
    
}
