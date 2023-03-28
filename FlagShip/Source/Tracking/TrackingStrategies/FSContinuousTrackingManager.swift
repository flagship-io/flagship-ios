//
//  FSContinuousTrackingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 27/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

class ContinuousTrackingManager: FSTrackingManager {
    // Create batch manager
    override init(_ pService: FSService, _ pTrackingConfig: FSTrackingConfig) {
        super.init(pService, pTrackingConfig)
    }

    override func sendHit(_ hitToSend: FSTrackingProtocol) {
        print("------------- SEND HIT CONTINUOUS BATCHING --------------------")
        batchManager.addTrackElement(hitToSend)
    }

    override func sendActivate(_ currentActivate: Activate) {
        self.service.activate(currentActivate.bodyTrack) { error in

            if error == nil {
                print(" ------------ Activate with sucess -------------")
            } else {
                print(" ------------ Activate failed -------------")
            }
        }
    }

    override func stopBatchingProcess() {
        batchManager.pauseBatchProcess()
    }

    override func resumeBatchingProcess() {
        batchManager.resumeBatchProcess()
    }
}
