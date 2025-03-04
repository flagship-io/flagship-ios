//
//  FSEmotionPageView.swift
//  Flagship
//
//  Created by Adel Ferguen on 25/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation
import UIKit

class FSEmotionPageView: FSPage {
    override init(_ location: String) {
        super.init(location)
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Size of the window browser
        let srValue = "\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height);"
        customParams.updateValue(srValue, forKey: "sr")

        // Set the vp
        customParams.updateValue("[\(UIScreen.main.nativeBounds.size.width),\(UIScreen.main.nativeBounds.size.height)]", forKey: "vp")
        // Does user has adblock?
        customParams.updateValue(false, forKey: "adb")
        // Number of bits per pixel of users machine
        customParams.updateValue("\(FSTools.getBitsPerPixel())", forKey: "sd")
        // Browser configuration on user tracking preference
        customParams.updateValue("unknown", forKey: "dnt")
        // List of installed fonts (Stringified array)
        customParams.updateValue("\(UIFont.familyNames)", forKey: "fnt")
        // Fake browser infos
        customParams.updateValue(false, forKey: "hlb")
        // Fake os infos
        customParams.updateValue(false, forKey: "hlo")
        // Fake resolution infos
        customParams.updateValue(false, forKey: "hlr")
        // Fake language infos
        customParams.updateValue(true, forKey: "hll")
        // Browser language
        customParams.updateValue(FSDevice.getDeviceLanguage() ?? "", forKey: "ul")
        // Machine type of the user
        customParams.updateValue(FSDevice.getDeviceType(), forKey: "dc")
        // Ratio between physical pixels and device-independent pixels (dips) on the device
        customParams.updateValue(UIScreen.main.scale, forKey: "pxr")
        // Amount of time subtracted from or added to Coordinated Universal Time (UTC) time to get the curre
        customParams.updateValue(FSTools.getAmountTimeInMinute(), forKey: "tof")
        // tsp
        customParams.updateValue("[0,false,false]", forKey: "tsp")
        // Send an empty list
        customParams.updateValue("[]", forKey: "plu")
        // Send empty string
        customParams.updateValue("", forKey: "ua")
        // Send empty string
        customParams.updateValue("", forKey: "dr")

        customParams.merge(super.bodyTrack) { _, new in new }
        // Remove qt
        customParams.removeValue(forKey: "qt")
        return customParams
    }
}
