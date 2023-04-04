//
//  FSPeriodicTrackingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 27/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class PeriodicTrackingManager: ContinuousTrackingManager {
    // Create batch manager

    override init(_ pService: FSService, _ pTrackingConfig: FSTrackingConfig, _ pCacheManager: FSCacheManager) {
        super.init(pService, pTrackingConfig, pCacheManager)
    }

    override func sendHit(_ hitToSend: FSTrackingProtocol) {
        print("------------- PERIODIC BATCHING --------------------")
    }

    override func sendActivate(_ currentActivate: Activate) {}
}
