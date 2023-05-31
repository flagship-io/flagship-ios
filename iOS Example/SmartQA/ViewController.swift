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
        let trackingConfig = FSTrackingConfig(poolMaxSize: 5, batchIntervalTimer: 10, strategy: .CONTINUOUS_CACHING)
        
        let conf: FlagshipConfig = FSConfigBuilder().withTrackingConfig(trackingConfig).withStatusListener { _ in
            
//            if newStatus == .READY {
//                Flagship.sharedInstance.sharedVisitor?.fetchFlags {
//                    let myFlag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "my_flag", defaultValue: "dflValue")
//
//                    print("The value for the flag si \(myFlag?.value())")
//                    myFlag?.userExposed()
//                    // Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen1"))
//                    // Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "KPI2"))
//                }
//            }
        }.build()
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23", config: conf)
        
        let v1 = Flagship.sharedInstance.newVisitor("visitor3105-abcdfer").withContext(context: ["testing_tracking_manager": true]).build()
        let myFalg = v1.getFlag(key: "my_flag", defaultValue: "dflt")
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        print("stop")
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        myFalg.userExposed()
    }
    
    /// Add one more activate
    @IBAction func activate() {
        let myFalg = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "my_flag", defaultValue: "dflt")
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        print("stop")
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
        myFalg?.userExposed()
    }
    
    @IBAction func sendHits() {
//        let v2 = Flagship.sharedInstance.newVisitor("visitor-B").withContext(context: ["testing_tracking_manager": true]).build()
//        // Send Hits
//        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
//        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA1"))
//        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA"))
//        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "smartQA1"))
        
        Flagship.sharedInstance.close()
    }
}
