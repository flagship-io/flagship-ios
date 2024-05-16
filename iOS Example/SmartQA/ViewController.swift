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
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23", config: FSConfigBuilder().withLogLevel(.ALL).build())
        
        let v1 = Flagship.sharedInstance.newVisitor("user19MarsBIs").withContext(context: ["testing_tracking_manager": true]).build()
        
        v1.fetchFlags {
            self.tableView?.reloadData()
            
            v1.getFlag(key: "add_payment_btn", defaultValue: "dfl").value()
        }
    }
    

    
    @IBAction func activate() {
        for i in 1 ... 1 {
            Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor", defaultValue: "aa").value()
        }
    }
    
    @IBAction func sendHits() {
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23")
        
        let v1 = Flagship.sharedInstance.newVisitor("user19MarsBIs").withContext(context: ["testing_tracking_manager": true]).build()

        // Start the SDK Flagship
        Flagship.sharedInstance.sharedVisitor?.getFlag(key: "add_payment_btn", defaultValue: "dfl").value()
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
        if let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "add_payment_btn", defaultValue: "dfl") {
            Flagship.sharedInstance.sharedVisitor?.clearContext()
            Flagship.sharedInstance.sharedVisitor?.updateContext("test", "stress")
            flag.visitorExposed()
        }

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
