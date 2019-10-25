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
        
        // Use the flagShip to get the title of cta_text
        let title =  ABFlagShip.sharedInstance.getModification("cta_text", defaultString: "default", activate: true)
        self.ctaButton.setTitle(title, for: .normal)
    }
    
    
    
    // Cancel Screen
    @IBAction func onCancelHome(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Click Shoping
    @IBAction func onClikcShoping(){
        
        // Use the flagShip to send Action Tracking
        // Create event for CTA Action
        let actionEvent:FSEventTrack = FSEventTrack(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "cta_Shop")
        actionEvent.label = "cta_Shop"
        actionEvent.eventValue = 1
        actionEvent.interfaceName = "HomeScreen"
        
        // Send Event Tracking
        ABFlagShip.sharedInstance.sendTracking(actionEvent)
        
        
        // Send Item track
        
        let itemTrack = FSItemTrack(transactionId: "itemTrack", name: "name")
        itemTrack.price = 123
        ABFlagShip.sharedInstance.sendTracking(itemTrack)
    }
}
