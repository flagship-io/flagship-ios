//
//  ViewController.swift
//  FlagShip
//
//  Created by Adel on 08/08/2019.
//  Copyright (c) 2019 Adel. All rights reserved.
//

import UIKit
import FlagShip

class ViewController: UIViewController {
    
    @IBOutlet var mainTitle:UILabel!
    
    @IBOutlet var newFeature:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.mainTitle.text = ABFlagShip.sharedInstance.getModification("titleBtn", defaultString: "default",activate: true)
        
        let isVip = ABFlagShip.sharedInstance.getModification("Feature1", defaultBool: false,activate: true)
        
        ABFlagShip.sharedInstance.updateContext(["key":1,"key1":true, "key2":"value"]) { (state) in
            
            // add you code once the context is sync
        }
        
        self.newFeature.isHidden = !isVip
    }
    
    
    
    
    
    @IBAction func back(){
        
        self.dismiss(animated: true) {
        }
    }


    @IBAction func sendAction(){
        
        let eventAction = FSEventTrack(.Action_Tracking, "iosAction", "iosLabel", 3)
        
       // let eventAction = FSEventTrack(.Action_Tracking, "iosEventWithoutValue")

        ABFlagShip.sharedInstance.sendTracking(eventAction)
        
    }
    
    
    @IBAction func sendPageEvent(){
        
        let eventPage = FSPageTrack("loginScreen")
        
        // add event
        
        eventPage.userIp = "168.13.12.0"
        eventPage.sessionNumber = 12
        eventPage.screenResolution = "200x200"
        ABFlagShip.sharedInstance.sendTracking(eventPage)
        
    }
    
    @IBAction func updateCampaign(){
        
        ABFlagShip.sharedInstance.updateContext(["isVipUser":false]) { (state) in
            
            DispatchQueue.main.async {
                
                let isVip = ABFlagShip.sharedInstance.getModification("Feature1", defaultBool: false,activate: true)
                self.newFeature.isHidden = !isVip
            }
           
        }
    }
    
    



}

