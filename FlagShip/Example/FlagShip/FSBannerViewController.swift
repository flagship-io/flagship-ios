//
//  FSBannerViewController.swift
//  FlagShip_Example
//
//  Created by Adel on 23/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import FlagShip



class FSBannerViewController: UIViewController {
    
    
    @IBOutlet var bannerBtn:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.bannerBtn.layer.cornerRadius = 10
        self.bannerBtn.layer.masksToBounds = true
        
        let title = ABFlagShip.sharedInstance.getModification("bannerTitle", defaultString: "More Infos",activate: true)
        self.bannerBtn.setTitle(title, for: .normal)
    }
    
    
    
    override var prefersStatusBarHidden: Bool{
        
        return true
    }
    
    // Exit
    @IBAction func cancel(){
        
        self.dismiss(animated: true, completion:nil)
    }
}
