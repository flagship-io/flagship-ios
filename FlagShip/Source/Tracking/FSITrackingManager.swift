//
//  FSITrackingManager.swift
//  Flagship
//
//  Created by Adel Ferguen on 27/03/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Foundation

protocol ITrackingManager {
    func sendHit(_ hitToSend: FSTrackingProtocol)

    func sendActivate(_ currentActivate: Activate, onCompletion: @escaping (Error?, [FSExposedInfo]?) -> Void)

    func stopBatchingProcess()

    func resumeBatchingProcess()
}
