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
        let title =  ABFlagShip.sharedInstance.getModification("cta_text", defaultString: "ouuups", activate: false)
        
        
        // Activate key
        //ABFlagShip.sharedInstance.activateModification(key: "cta_text")
        
        
        // Activate modification to tell Flagship that the user has seen this specific variation
        ABFlagShip.sharedInstance.activateModification(key: "cta_text")

        
        print( " Value for FlagShip is = \(ABFlagShip.sharedInstance.getModification("arrayValues", defaultInt: 2, activate: true))")

        self.ctaButton.setTitle(title, for: .normal)
    }
    
    
    
    // Cancel Screen
    @IBAction func onCancelHome(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Click Shoping
    @IBAction func onClikcShoping(){
        
        
        
 
       
        // Create event for CTA Action
        // The event action you give here is the name who should be displayed on the report
        let actionEvent:FSEventTrack = FSEventTrack(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "cta_Shop")
        actionEvent.label = "cta_Shop_label"
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
