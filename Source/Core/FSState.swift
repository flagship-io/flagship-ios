//
//  FSState.swift
//  Flagship
//
//  Created by Adel on 06/07/2021.
//  Copyright © 2021 FlagShip. All rights reserved.
//



import Foundation


@objc public enum RGPD: NSInteger {
    
    case AUTHORIZE_TRACKING
    
    case UNAUTHORIZE_TRACKING
}


class FSState {
    
    internal var _rgpd :RGPD
    
    init(){
        
        _rgpd = .UNAUTHORIZE_TRACKING
    }
    
    

    
    func getRgpd()->RGPD{
        
        return _rgpd
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
        
        if (_rgpd == .UNAUTHORIZE_TRACKING){
            
        }else{
            
            ret = true
        }
        return ret
    }
    
    
    
    private func authorizedProtocol(){
        
        // Todo
        
    }
    
    
    
    private func unAuthorizedProtocol(){
        
        FSLogger.FSlog(" ##############@ Clean cache #############", .Campaign)
        // Remove data event
        DispatchQueue(label: "flagShip.RemoveStoredEvents.queue").async(execute: DispatchWorkItem {
            Flagship.sharedInstance.service?.threadSafeOffline.removeAllSavedTracking()
            FSCacheManager().deleteAllCachedData()
        })
    }
    
}
