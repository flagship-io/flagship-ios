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
       
        let conf: FlagshipConfig = FSConfigBuilder().build()
        
        print(Flagship.sharedInstance.getStatus())
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23", config: conf)
        
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "v1", hasConsented: true).withContext(context: ["isQA": true]).withFetchFlagsStatus { st, reason in
            
            print(reason.rawValue)
            
            print(st.rawValue)
            
        }.build()
    }
    
    /// Add one more activate
    @IBAction func activate() {
        // Print state for the flag
 
        
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            print(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue)
            
           
        }
    }
    
    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.updateContext(["key": "val"])
    }
}
