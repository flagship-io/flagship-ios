//
//  FSCartViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 25/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var feeDelivery: Float = 10.0

    // List of product
    let listProduct: [FSProduct] = [FSProduct("SALOMON Speedcross 3 Trail Running", "salomon3", "40", "130 EUR"),
                                   FSProduct("SALOMON Speedcross 4 Trail Running", "salomon4", "41", "150 EUR")]

    @IBOutlet var priceDelivery: UILabel!

    @IBOutlet var checkoutBtn: UIButton!

    @IBOutlet var listTableView: UITableView!

    var isNewUser: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        checkoutBtn.layer.cornerRadius = checkoutBtn.frame.height / 2
        checkoutBtn.layer.masksToBounds = true

        if Flagship.sharedInstance.getModification("isVip", defaultBool: false, activate: true) {

            priceDelivery.text = "Free for vip"

        } else {

            priceDelivery.text = String(format: "%.01f EUR ", feeDelivery)
        }

        // Send event page
        let eventPage: FSPage = FSPage("basketScreen")
        Flagship.sharedInstance.sendHit(eventPage)

        //// send new object
        let pageHit = FSPage("basketScreen")
        Flagship.sharedInstance.sendHit(pageHit)
    }

    override func viewDidAppear(_ animated: Bool) {

        if isNewUser {

            let msg = Flagship.sharedInstance.getModification("persoMessage", defaultString: "Ouuups", activate: true)
            displayPopPromo(msg)
        }
    }

    @IBAction func cancel() {

        dismiss(animated: true, completion: nil)
    }

    /// Delegate table View
    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return listProduct.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: FSProductCell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! FSProductCell
        let item: FSProduct = listProduct[indexPath.row]
        cell.configCell(item)
        return cell
    }

    func displayPopPromo(_ msg: String) {

       let alert =  UIAlertController(title: "Welcome", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }

    /// Check out

    @IBAction func oncheckOut() {

        //// new transac hit
        let transac: FSTransaction = FSTransaction(transactionId: "transacId_2306", affiliation: "june_transaction_23")
        transac.currency = "EUR"
        transac.itemCount = 0
        transac.paymentMethod = "PayPal"
        transac.shippingMethod = "Fedex"
        transac.tax = 2.6
        transac.revenue = 15
        transac.shipping = 3.5
        Flagship.sharedInstance.sendHit(transac)

        /// Create item hit
        let itemHit = FSItem(transactionId: "idTransaction", name: "itemName", code: "codeSku")
        /// Set price
        itemHit.price = 20
        /// set category
        itemHit.category = "shoes"
        /// set quantity
        itemHit.quantity = 2

        /// Send Item
        Flagship.sharedInstance.sendHit(itemHit)
    }

    @IBAction func onCancel() {

        let cancelEvent: FSEvent = FSEvent(eventCategory: .User_Engagement, eventAction: "cta_cancelBasket")
        Flagship.sharedInstance.sendHit(cancelEvent)

        /// send new event
        let cancelHit = FSEvent(eventCategory: .User_Engagement, eventAction: "cta_cancelBasket_hit")
        Flagship.sharedInstance.sendHit(cancelHit)

    }

}

/// Product class
public class FSProduct {

    var name: String!
    var imageString: String!
    var size: String!
    var price: String!

    init(_ name: String, _ photoName: String, _ size: String, _ price: String) {

        self.name = name
        self.imageString = photoName
        self.size = size
        self.price = price
    }
}
