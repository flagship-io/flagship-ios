//
//  FSApac.swift
//  Flagship
//
//  Created by Adel on 27/02/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit


/// :nodoc:
@objc public enum FSRegion:NSInteger {
    
    case APAC = 0
    
    case REST_OF_THE_WORD
}

@objc public class FSApacRegion: NSObject {
    
    /// XApi Key
    internal(set) public var apiKey:String
    
    public init(_ pApiKey:String) {
        
        apiKey = pApiKey
    }
    
}
