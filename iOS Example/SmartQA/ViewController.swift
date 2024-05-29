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
        // Create visitor
        let visitor1 = Flagship.sharedInstance.newVisitor(visitorId: "visitor_1", hasConsented: true).build()
       
        visitor1.setConsent(hasConsented: false)
        
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23")
 
        let v1 = Flagship.sharedInstance.newVisitor(visitorId: "user2705", hasConsented: true).withContext(context: ["isQA": true]).withFetchFlagsStatus { newStatus, reason in
            
            print(newStatus.rawValue)
            print(reason.rawValue)
        }.build()
        
        v1.fetchFlags {
            
            
            let flag = v1.getFlag(key: "btnColor")
            
            flag.visitorExposed()
            
            flag.valueBis(defaultValue: "defaultValue", visitorExposed: false)

            
            print("aa")
            
        }
    }
 
    /// Add one more activate
    @IBAction func activate() {}

    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.updateContext(["key": "val"])
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
        cell.textLabel?.text = "cell"
        let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor")
        
        cell.detailTextLabel?.text = flag?.value(defaultValue: "dflt") as? String ?? ""
        if let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "add_payment_btn") {
            Flagship.sharedInstance.sharedVisitor?.clearContext()
            Flagship.sharedInstance.sharedVisitor?.updateContext("test", "stress")
            flag.visitorExposed()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_bannerA").value(defaultValue: false)
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
