//
//  Flagship+EmotionAI.swift
//  Flagship
//
//  Created by Adel Ferguen on 24/09/2025.
//  Copyright © 2025 FlagShip. All rights reserved.
//

#if os(iOS) || os(tvOS)
public extension Flagship {
    // Start SDK (async-await)
    func start(envId: String, apiKey: String, config: FlagshipConfig = FSConfigBuilder().build()) async {
        await withCheckedContinuation { continuation in
            FSSettings().fetchRessources(envId: envId) { extras, error in
                if error == nil {
                    // Set the collected
                    Flagship.sharedInstance.eaiCollectEnabled = extras?.accountSettings?.eaiCollectEnabled ?? false
                    // Set the Activation
                    Flagship.sharedInstance.eaiActivationEnabled = extras?.accountSettings?.eaiActivationEnabled ?? false

                    FlagshipLogManager.Log(level: .DEBUG, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.MESSAGE("The Emotion AI collection is \(Flagship.sharedInstance.eaiCollectEnabled)"))
                    FlagshipLogManager.Log(level: .DEBUG, tag: .INITIALIZATION, messageToDisplay: FSLogMessage.MESSAGE("The Emotion AI activation is \(Flagship.sharedInstance.eaiActivationEnabled)"))

                } else {
                    // Error on get ressource
                    // The false default value is applied to EAI
                    // NO Collect
                }
                Flagship.sharedInstance.start(envId: envId, apiKey: apiKey, config: config)
                continuation.resume()
            }
        }
    }
}
#endif
