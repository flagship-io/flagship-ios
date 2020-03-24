//
//  FSHomeViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 24/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import Flagship



class FSHomeViewController: UIViewController {
    
    
    @IBOutlet var ctaButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the flagShip to get the title of cta_text
        let title =  Flagship.sharedInstance.getModification("cta_text", defaultString: "default", activate: false)
        
        // Use FlagShip to get color
        let colorHexTitle =  Flagship.sharedInstance.getModification("cta_color", defaultString: "#163d42", activate: false)
        
       
        
        
        // Activate modification to tell Flagship that the user has seen this specific variation
        Flagship.sharedInstance.activateModification(key: "cta_text")
        
       
        
        
        self.ctaButton.setTitle(title, for: .normal)
        self.ctaButton.backgroundColor = UIColor(hexString: colorHexTitle, alpha: 1.0)
    }
    
    
    
    // Cancel Screen
    @IBAction func onCancelHome(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Click Shoping
    @IBAction func onClikcShoping(){
 
       
        // Create event for CTA Action
        // The event action you give here is the name who should be displayed on the report
        let actionEvent:FSEvent = FSEvent(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "cta_Bucketing")
        actionEvent.label = "cta_Bucketing_label"
        actionEvent.eventValue = 1
        actionEvent.interfaceName = "HomeScreen"
        // Send Event Tracking
        Flagship.sharedInstance.sendHit(actionEvent)
        
        
        
        /// Send the new event
        let action:FSEvent = FSEvent(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "cta_Bucketing")
        actionEvent.label = "cta_Bucketing_label"
        actionEvent.eventValue = 1
        actionEvent.interfaceName = "HomeScreen"
        // Send Event Tracking
        Flagship.sharedInstance.sendHit(action)
    }
    
    
    
    
}
