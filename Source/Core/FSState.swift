//
//  FSState.swift
//  Flagship
//
//  Created by Adel on 06/07/2021.
//  Copyright © 2021 FlagShip. All rights reserved.
//



import Foundation


@objc public enum FlagshipState: NSInteger {

    case READY
    case NOT_READY
    case PANIC
    
}


@objc public enum RGPD: NSInteger {
    
    case AUTHORIZE_TRACKING
    
    case UNAUTHORIZE_TRACKING
}



class FSState {
    
    internal var _state:FlagshipState
    internal var _rgpd :RGPD
    
    init(){
        
        _state = .NOT_READY
        _rgpd = .UNAUTHORIZE_TRACKING
    }
    
    
    func getState()->FlagshipState{
        
        return _state
    }
    
    func getRgpd()->RGPD{
        
        return _rgpd
    }
    
    func updateState(pState:FlagshipState){
        
        self._state = pState
    }
    
    func updateRgpd(_ newValue:RGPD){
        
        _rgpd = newValue
        
        switch _rgpd {
        case .AUTHORIZE_TRACKING:
            authorizedProtocol()
        default:
            unAuthorizedProtocol()
        }
    }
    
    
    func isAuthorized()->Bool{
        
        var ret = false
        
        if (_rgpd == .UNAUTHORIZE_TRACKING || _state == .PANIC){
            
        }else{
            
            ret = true
        }
        return ret
    }
    
    
    
    private func authorizedProtocol(){
        
        // Todo
        
    }
    
    
    
    private func unAuthorizedProtocol(){
        
        print(" ##############@ Clean cache #############")
        // Purge data event
        DispatchQueue(label: "flagShip.FlushStoredEvents.queue").async(execute: DispatchWorkItem {
            Flagship.sharedInstance.service?.threadSafeOffline.flushStoredEvents()
            FSCacheManager().deleteAllCachedData()
        })
    }
    
}
