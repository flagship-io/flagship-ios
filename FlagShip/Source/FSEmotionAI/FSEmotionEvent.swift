//
//  FSEmotionEvent.swift
//  Flagship
//
//  Created by Adel Ferguen on 22/11/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Foundation

// Represent click en move scroll
class FSEmotionEvent: FSTracking {
    // Position of the clic : y,x, last 5 digits from timestamp, clic duration in ms

    var posX: String
    var posY: String
    var last5digitTimeStmap: String
    var last5digitTimeStmapBis: String

    var clickDuration: String

    var cursorPosition: String

    public var currentScreen: String = ""

    init(_ pX: String, _ pY: String, _ pClickDuration: String, _ pCursorPosition: String = "") {
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
            customParams.updateValue("\(self.posY),\(self.posX),\(self.last5digitTimeStmap),\(self.clickDuration)", forKey: "cpo") // "1016,978,98575,134"
        }

        // Set the current screen
        customParams.updateValue(self.currentScreen, forKey: "dl")

        // Set the resolution
        let srValue = "\(UIScreen.main.bounds.width),\(UIScreen.main.bounds.height);"
        customParams.updateValue(srValue, forKey: "sr")
        //
        //        let lastDigitForScroll_1 = "\((Int(self.last5digitTimeStmap) ?? 0) - 10)"
        //        let lastDigitForScroll_2 = "\((Int(self.last5digitTimeStmap) ?? 0) - 11)"
        //        let lastDigitForScroll_3 = "\((Int(self.last5digitTimeStmap) ?? 0) - 12)"
        //        let lastDigitForScroll_4 = "\((Int(self.last5digitTimeStmap) ?? 0) - 13)"

        customParams.updateValue(self.cursorPosition, forKey: "cp")

        // customParams.updateValue("230,215,\(lastDigitForScroll_1);231,216,\(lastDigitForScroll_2);233,217,\(lastDigitForScroll_3);235,219,\(lastDigitForScroll_4)", forKey: "spo")

        customParams.merge(self.communBodyTrack) { _, new in new }

        // Remove qt
        customParams.removeValue(forKey: "qt")
        return customParams
    }
}
