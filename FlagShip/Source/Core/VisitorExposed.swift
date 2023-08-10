//
//  VisitorExposed.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

public class VisitorExposed: NSObject {
    public var id: String
    public var anonymousId: String?
    public var context: [String: Any] = [:]
    
    
    
    init(id: String, anonymousId: String? = nil, context: [String : Any]) {
        self.id = id
        self.anonymousId = anonymousId
        self.context = context
    }
}
