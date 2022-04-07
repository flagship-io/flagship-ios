//
//  FSCustomTools.swift
//  QApp
//
//  Created by Adel on 30/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Foundation
import UIKit

internal class FSCTools {

    public class func roundButton(_ button: UIButton?) {

        button?.layer.cornerRadius = 5
        button?.layer.masksToBounds =  true
    }
}
