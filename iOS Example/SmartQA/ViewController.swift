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
        // Create FSTrackingManagerConfig
        // - Time Intreval : 20
        // - Maximum size pool : 20
        // - Strategy : BATCH_CONTINUOUS_CACHING
        
        let trackingConfig = FSTrackingManagerConfig(poolMaxSize: 20, batchIntervalTimer: 20, strategy: .CONTINUOUS_CACHING)
        
        // Create FlagshipConfig
       
        let conf: FlagshipConfig = FSConfigBuilder().withTrackingManagerConfig(trackingConfig).withCacheManager(FSCacheManager(visitorLookupTimeOut: 30, hitCacheLookupTimeout: 40)).build()
        
        print(Flagship.sharedInstance.getStatus())
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23", config: conf)
        
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "v1", hasConsented: true).withContext(context: ["isQA": true]).build()
        
        print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)
        
        v1.fetchFlags {
            print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)
            
            v1.updateContext(["aa": 1])
            
            print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)
        }
        
        print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)

        print(Flagship.sharedInstance.getStatus())
    }
    
    /// Add one more activate
    @IBAction func activate() {
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)
            
            let flg = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor", defaultValue: "dfl")
            
            Flagship.sharedInstance.sharedVisitor?.fetchFlags(onFetchCompleted: {
                print(flg?.status.rawValue)
            })
        }
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
