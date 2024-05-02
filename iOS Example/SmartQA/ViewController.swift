//
//  ViewController.swift
//  SmartQA
//
//  Created by Adel Ferguen on 19/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit
class ViewController: UIViewController /* , UITableViewDelegate, UITableViewDataSource */ {
    @IBOutlet var startQABtn: UIButton?

    @IBOutlet var activateQABtn: UIButton?

    @IBOutlet var tableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startQA() {
        Flagship.sharedInstance.start(envId: "bkk9glocmjcg0vtmdlng", apiKey: "DxAcxlnRB9yFBZYtLDue1q01dcXZCw6aM49CQB23")

        let user = Flagship.sharedInstance.newVisitor(visitorId: "user19MarsBIs", hasConsented: true).withContext(context: ["isVipClient": true]).build()

        user.fetchFlags {
            let nf = user.getFlag(key: "notFound")

            let v = nf.value(defaultValue: "toto")

            nf.exists()

            let md = nf.metadata()

            // User get all flag
            let allFlag = user.getFlagMap()

            // Get Value "x_paiement_enabled" : true
            let f1 = allFlag["x_paiement_enabled"] // New flag object V4
            // Activate
            f1?.visitorExposed()
            // Exist
            print("The flag \(String(describing: f1?.exists()))")
            // metadata
            print(f1?.metadata().toJson() ?? "")

            f1?.visitorExposed() /// ça passe
            /// Never called vlaue before ==> warnign ?, ====> should actiavte ?, ====> si oui exposeCallback with defaulValue = null

            // Get Value
            let wrongValue = f1?.value(defaultValue: "oups") // should return "oups",
            // Should we actiavte the flag event the type is wrong ??? , on est plus tenté de dire NON  , c'est le meme comportement de la prod
            // Expose callBack n'est pas triggger

            print(" The wrong valus is \(String(describing: wrongValue))")

            f1?.visitorExposed() // es qu'on active ou pas ?
            /// - Si on active ===> on met un warning ? on se basant sur le dflt value stocké, dans ce cas String
            /// aussi trigger exposeCallback avec le default value : "oups" ou Null ??? , plus tenté de dire "oups"
            /// OU
            /// - On n active pas, car la dernière defaultValue n'est pas identique à la value du flag, dans ce cas Bool / String
            /// ExposeCallback n'est pas trigger
            ///
            /// Passer un boolean param dans la fct expose
            /// si on passe true ==> 55
            /// si on passse false ==> 58

            let correctValue = f1?.value(defaultValue: false) // should return boolean
            print(" The wrong valus is \(String(describing: correctValue))")
            // Activate comportement normal avec exposeCallback normal comme la prod
        }
    }

    /// Add one more activate
    @IBAction func activate() {
        if let allFlag = Flagship.sharedInstance.sharedVisitor?.getFlagMap() {
            allFlag.exposeAll()
            // Attention ici il faudra check le process des expose evoqué à la ligne 55
        }
    }

    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.updateContext(["key": "val"])
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // let cell = tableView.dequeueReusableCell(withIdentifier: "idCell")
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath)
//
//        cell.textLabel?.text = "cell"
//
//        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
//            let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_banner", defaultValue: false).value()
//        }
//
//        let flag = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor", defaultValue: "dfl")
//
//        cell.detailTextLabel?.text = flag?.value() as? String ?? ""
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let flagBis = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "ads_bannerA", defaultValue: false).value()
//        // Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
//
//        for i in 0 ... 3 {
//            Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen("screen"))
//        }
//    }

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
