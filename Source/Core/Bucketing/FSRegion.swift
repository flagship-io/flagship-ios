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
    
    /// For APAC Region
    case APAC = 0
    
    /// The rest of the world
    case REST_OF_THE_WORD
}

/**
 The class that represent Region
 */
@objc public class FSRegion: NSObject {
    
    /// XApi Key for athentication
    internal(set) public var apiKey:String
    
    
    /// Region type
    internal(set) public var region:FSRegionType

    /// init by default with Apac region mode
    public init(_ pApiKey:String) {
        
        apiKey = pApiKey
        
        region = .APAC
    }
    
}
