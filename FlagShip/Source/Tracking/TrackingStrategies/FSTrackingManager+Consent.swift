//
//  FSTrackingManager+Consent.swift
//  Flagship
//
//  Created by Adel Ferguen on 04/04/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

extension FSTrackingManager {
    // Remove hits for visitorId and keep the consent hits
    func flushTrackAndKeepConsent(_ visitorId: String) {
        var listIdsToRemove = self.batchManager.flushTrackAndKeepConsent(visitorId)
        if !listIdsToRemove.isEmpty {
            self.cacheManager?.flushHits(listIdsToRemove)
        }
    }
}
