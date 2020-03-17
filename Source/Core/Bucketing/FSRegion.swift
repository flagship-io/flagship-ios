//
//  FSRegion.swift
//  Flagship
//
//  Created by Adel on 04/03/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation



/// :nodoc:
@objc public enum FSRegionType:NSInteger {
    
    
    case APAC = 0
    
    case REST_OF_THE_WORD
}

@objc public class FSRegion: NSObject {
    
    /// XApi Key
    internal(set) public var apiKey:String
    
    
    /// Region
    internal(set) public var region:FSRegionType

    /// init by default with Apac
    public init(_ pApiKey:String) {
        
        apiKey = pApiKey
        
        region = .APAC
    }
    
}
