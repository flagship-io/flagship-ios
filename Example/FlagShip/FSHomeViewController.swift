//
//  FSHomeViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 24/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import FlagShip





class FSHomeViewController: UIViewController {

    
    
    @IBOutlet var ctaButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get title for cta
        let title =  ABFlagShip.sharedInstance.getModification("cta_text", defaultString: "SHOP", activate: true)
        self.ctaButton.setTitle(title, for: .normal)
 
    }
    
    
    @IBAction func onCancelHome(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Click Shoping
    @IBAction func onClikcShoping(){
        
        
        // Create event for CTA Action
        let actionEvent:FSEventTrack = FSEventTrack(.Action_Tracking, "cta_Shop")
        actionEvent.label = "cta_Shop"
        actionEvent.value = 1
        actionEvent.interfaceName = "HomeScreen"
        
        // Send Event Tracking
        ABFlagShip.sharedInstance.sendTracking(actionEvent)
    }
}
