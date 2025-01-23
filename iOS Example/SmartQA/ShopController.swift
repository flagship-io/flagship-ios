//
//  ShopController.swift
//  SmartQA
//
//  Created by Adel Ferguen on 24/12/2024.
//  Copyright © 2024 FlagShip. All rights reserved.
//

import Flagship
import UIKit

class ShopController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        Flagship.sharedInstance.sharedVisitor?.onAppScreenChange("ShopScreen")

        // Do any additional setup after loading the view.
    }

    @IBAction func onclick() {
        print("@@@@@@@@@@@@ on click button @@@@@@@@@@@@")
    }
}
