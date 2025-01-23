//
//  FSEmotionEvent.swift
//  Flagship
//
//  Created by Adel Ferguen on 22/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation
import UIKit

// Represent click en move scroll
class FSEmotionEvent: FSTracking {
    var posX: String
    var posY: String
    var last5digitTimeStmap: String
    var last5digitTimeStmapBis: String

    var clickDuration: String

    var cursorPosition: String
    var scrollPosition: String

    public var currentScreen: String = "./"

    init(_ pX: String, _ pY: String, pClickDuration: String = "", pCursorPosition: String = "", pScrollPosition: String = "") {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumIntegerDigits = 0
        formatter.maximumFractionDigits = 5
        let number = NSNumber(value: NSDate().timeIntervalSince1970)
        let numberBis = NSNumber(value: NSDate().timeIntervalSince1970)

        let formattedValue = formatter.string(from: number)!
        self.last5digitTimeStmap = formattedValue.replacingOccurrences(of: ",", with: "")

        let formattedValueBis = formatter.string(from: numberBis)!
        self.last5digitTimeStmapBis = formattedValueBis.replacingOccurrences(of: ",", with: "")

        self.posX = pX
        self.posY = pY
        self.clickDuration = pClickDuration
        self.cursorPosition = pCursorPosition
        self.scrollPosition = pScrollPosition
        super.init()
        self.type = .EMOTION_AI
    }

    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }

    override var bodyTrack: [String: Any] {
        var customParams = [String: Any]()
        customParams.updateValue(self.type.typeString, forKey: "t")

        if self.posX.count != 0 && self.posY.count != 0 {
            // Set the Click Position
            customParams.updateValue("\(self.posY),\(self.posX),\(self.last5digitTimeStmap),\(self.clickDuration)", forKey: "cpo")
        }
        // Set the current screen
        customParams.updateValue(self.currentScreen, forKey: "dl")
        // Set the resolution
        let srValue = "\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height);"
        customParams.updateValue(srValue, forKey: "sr")
        customParams.updateValue(self.cursorPosition, forKey: "cp")
        customParams.updateValue(self.scrollPosition, forKey: "spo")

        customParams.merge(self.communBodyTrack) { _, new in new }

        // Remove qt
        customParams.removeValue(forKey: "qt")
        return customParams
    }
}
