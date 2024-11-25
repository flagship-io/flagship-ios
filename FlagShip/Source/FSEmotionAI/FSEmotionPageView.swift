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
    var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"

    override init(_ location: String) {
        super.init(location)
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override var bodyTrack: [String: Any] {
        var customParams = [String: Any]()

        // Set the resolution
        let srValue = "\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height);"
        customParams.updateValue(srValue, forKey: "sr")
        // Set the user agent
        customParams.updateValue(self.userAgent, forKey: "ua")
        // Set the language
        customParams.updateValue("fr-FR", forKey: "ul")
        // Set the vp
        customParams.updateValue("[\(UIScreen.main.nativeBounds.size.width),\(UIScreen.main.nativeBounds.size.height)]", forKey: "vp")

        /// Add static infos
        customParams.updateValue(false, forKey: "adb")
        customParams.updateValue(true, forKey: "hlb")
        customParams.updateValue(true, forKey: "hll")
        customParams.updateValue(true, forKey: "hlo")
        customParams.updateValue(true, forKey: "hlr")
        customParams.updateValue(120, forKey: "tof")
        customParams.updateValue("24", forKey: "sd")
        customParams.updateValue("[\"Andale Mono\", \"Arial\"]", forKey: "fnt")
        customParams.updateValue("[0,false,false]", forKey: "tsp")
        customParams.updateValue("iphone", forKey: "dc")
        customParams.updateValue("Unknown", forKey: "dnt")
        customParams.updateValue("click tunnel auto", forKey: "ec")
        customParams.updateValue("[\"PDF Viewer::Portable Document Format::application/pdf~pdf,text/pdf~pdf\", \"WebKit built-in PDF::Portable Document Format::application/pdf~pdf,text/pdf~pdf\"]", forKey: "plu")
        customParams.updateValue(1.2, forKey: "pxr")
        customParams.updateValue("https://www.google.com?search=toto", forKey: "dr")
        customParams.updateValue(1.2, forKey: "pxr")

        customParams.merge(super.bodyTrack) { _, new in new }
        // Remove qt
        customParams.removeValue(forKey: "qt")

        return customParams
    }
}
