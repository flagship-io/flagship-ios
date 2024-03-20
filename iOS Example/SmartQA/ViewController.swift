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
        
        let v1 = Flagship.sharedInstance.newVisitor("user19MarsBIs").withContext(context: ["testing_tracking_manager": true]).build()
        
        v1.fetchFlags {
            self.tableView?.reloadData()
        }
    }
    
    /// Add one more activate
    @IBAction func activate() {
        // Start the SDK Flagship
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "idCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        
        cell.textLabel?.text = "cell"
        
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_banner", defaultValue: false).value()
        }
        
        let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor", defaultValue: "dfl")
        
        cell.detailTextLabel?.text = flag?.value() as? String ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_bannerA", defaultValue: false).value()
        // Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
        
        for i in 0 ... 3 {
            Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
        }
    }
}
