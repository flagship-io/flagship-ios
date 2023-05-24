//
//  ViewController.swift
//  SmartQA
//
//  Created by Adel Ferguen on 19/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit
class ViewController: UIViewController {
    @IBOutlet var startQABtn: UIButton?
    
    @IBOutlet var activateQABtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startQA() {
        let trackingConfig = FSTrackingConfig(poolMaxSize: 5, batchIntervalTimer: 10, strategy: .PERIODIC_CACHING)
        
        let conf: FlagshipConfig = FSConfigBuilder().withTrackingConfig(trackingConfig).withStatusListener { newStatus in
            
            if newStatus == .READY {

            }
        }.build()
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23", config: conf)
        
        let v1 = Flagship.sharedInstance.newVisitor("visitor-A").withContext(context: ["testing_tracking_manager": true]).isAuthenticated(true).build()
        
        v1.fetchFlags {
            print("stop") /// Go OFFLINE
            let myFlag = v1.getFlag(key: "my_flag", defaultValue: "dflValue")
            print("stop") /// Go ONLINE
            myFlag.userExposed()
     
           
            v1.sendHit(FSScreen("screen1"))
            
            let v2 = Flagship.sharedInstance.newVisitor("visitor-B").withContext(context: ["testing_tracking_manager": true]).isAuthenticated(true).build()
            
            v2.fetchFlags {
                let myFlagBis = v2.getFlag(key: "my_flag", defaultValue: "dflValue")
                myFlagBis.userExposed()
                
                v2.sendHit(FSScreen("screen2"))
            }
        }
    }
    
    /// Add one more activate
    @IBAction func activate() {
        let v2 = Flagship.sharedInstance.newVisitor("visitor-B").withContext(context: ["testing_tracking_manager": true]).build()
        let myFalg = v2.getFlag(key: "my_flag", defaultValue: "dflt")
        myFalg.userExposed()
    }
    
    @IBAction func sendHits() {
        let v2 = Flagship.sharedInstance.newVisitor("visitor-B").withContext(context: ["testing_tracking_manager": true]).build()
        // Send Hits
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA1"))
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA1"))
    }
}
