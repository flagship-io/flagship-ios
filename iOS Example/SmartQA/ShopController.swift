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

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
