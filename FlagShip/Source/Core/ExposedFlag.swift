//
//  ExposedFlag.swift
//  Flagship
//
//  Created by Adel Ferguen on 09/08/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import UIKit

public class ExposedFlag:NSObject {
    // Key for flag
    var key: String

    // Default value
    var defaultValue: Any?

    // Get metadata
    var metadata: FSFlagMetadata

    init(key: String, defaultValue: Any? = nil, metadata: FSFlagMetadata) {
        self.key = key
        self.defaultValue = defaultValue
        self.metadata = metadata
    }
}
