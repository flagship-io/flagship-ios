//
//  ViewController.swift
//  SmartQA
//
//  Created by Adel Ferguen on 19/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var startQABtn: UIButton?

    @IBOutlet var activateQABtn: UIButton?
    
    @IBOutlet var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startQA() {
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23")
        
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "user19MarsBIs", hasConsented: true).withContext(context: ["testing_tracking_manager": true]).withFetchFlagsStatus { newStatus, reason in
            
            print(newStatus.rawValue)
            print(reason.rawValue)
        }.build()
        
        v1.fetchFlags {
            self.tableView?.reloadData()
        }
    }

    /// Add one more activate
    @IBAction func activate() {
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_banner", defaultValue: false).value()
            
         }
    }

    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.updateContext(["key": "val"])
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "idCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        
        cell.textLabel?.text = "cell"
        
//        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
//            let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_banner", defaultValue: false).value()
//        }
        
        let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor", defaultValue: "dfl")
        
        cell.detailTextLabel?.text = flag?.value() as? String ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_bannerA", defaultValue: false).value()
        // Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
        
        for i in 0 ... 3 {
            Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
        }
    }
    
    func todoc() {
        let visitor1r = Flagship.sharedInstance.newVisitor(visitorId: "userId", hasConsented: true)
            .withContext(context: ["age": 32, "isVip": true])
            .isAuthenticated(true)
            .build()
        
        let visitor1 = Flagship.sharedInstance.newVisitor(visitorId: "userId", hasConsented: true)
            .withContext(context: ["age": 32, "isVip": true])
            .isAuthenticated(true)
            .build()

        // To check if Flagship have to make a decision with the data you are providing at the SDK init you should fetch the flags
        visitor1.fetchFlags {
            // Fetch completed , you can retreive your flags
        }

        // Update the visitor context with lastPurchaseDate key and the value is 1615384464
        visitor1.updateContext("lastPurchaseDate", 1615384464)

        // Your visitor context has changed (you have updated it) you should fetch the flags to check if the decision has changed
        visitor1.fetchFlags {
            // Fetch completed , you can retreive your flags
        }
    }
}
