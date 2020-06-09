//
//  FSCartViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 25/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    var feeDelivery:Float = 10.0
    
    // List of product
    let listProduct:[FSProduct] = [FSProduct("SALOMON Speedcross 3 Trail Running", "salomon3", "40", "130 EUR"),
                                   FSProduct("SALOMON Speedcross 4 Trail Running", "salomon4", "41", "150 EUR")]
    
    @IBOutlet var priceDelivery:UILabel!

    @IBOutlet var checkoutBtn:UIButton!
    
    @IBOutlet var listTableView:UITableView!
    
    var isNewUser:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkoutBtn.layer.cornerRadius = checkoutBtn.frame.height / 2
        checkoutBtn.layer.masksToBounds = true
        
        
        
        
        if (Flagship.sharedInstance.getModification("isVip", defaultBool:false, activate: true)){
            
            priceDelivery.text = "Free for vip"
            
        }else{
            
            priceDelivery.text = String(format: "%.01f EUR ", feeDelivery)
        }
        
        
        
        // Send event page
        let eventPage:FSPage = FSPage("basketScreen")
        Flagship.sharedInstance.sendHit(eventPage)
        
        
        //// send new object
        let pageHit = FSPage("basketScreen")
        Flagship.sharedInstance.sendHit(pageHit)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (isNewUser){
            
            let msg = Flagship.sharedInstance.getModification("persoMessage", defaultString: "Ouuups", activate: true)
            displayPopPromo(msg)
        }
    }
    
    
    @IBAction func cancel(){
        
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
        
        let cell:FSProductCell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! FSProductCell
        let item:FSProduct = listProduct[indexPath.row]
        cell.configCell(item)
        return cell
    }
    
    
    
    func displayPopPromo(_ msg:String){
        
       let alert =  UIAlertController(title: "Welcome", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /// Check out
    
    @IBAction func oncheckOut(){
        
       

                
        // The affiliation is the name of transaction that should be appear in the report
        
        let transacEvent:FSTransaction = FSTransaction(transactionId:"transacId", affiliation: "BasketTransac")
        transacEvent.currency = "EUR"
        transacEvent.itemCount = 0
        transacEvent.paymentMethod = "PayPal"
        transacEvent.shippingMethod = "Fedex"
        transacEvent.tax = 2.6
        transacEvent.revenue = 15
        transacEvent.shipping = 3.5
        Flagship.sharedInstance.sendHit(transacEvent)
        
        
        //// new transac hit
        let transac:FSTransaction = FSTransaction(transactionId:"transacId", affiliation: "BasketTransac_hit")
        transacEvent.currency = "EUR"
        transacEvent.itemCount = 0
        transacEvent.paymentMethod = "PayPal"
        transacEvent.shippingMethod = "Fedex"
        transacEvent.tax = 2.6
        transacEvent.revenue = 15
        transacEvent.shipping = 3.5
        Flagship.sharedInstance.sendHit(transac)
        
        
        
        
        //// create item
        let item = FSItem(transactionId: "transacId", name: "itemName", code:"sku47")
        Flagship.sharedInstance.sendHit(item)
        
        
        /// create old item
        let oldItem = FSItem(transactionId: "transacId", name: "itemName", code: "sku47")
        Flagship.sharedInstance.sendHit(oldItem)
    }
    
    
    
    @IBAction func onCancel(){
        
        let cancelEvent:FSEvent = FSEvent(eventCategory: .User_Engagement, eventAction: "cta_cancelBasket")
        Flagship.sharedInstance.sendHit(cancelEvent)
        
        
        /// send new event
        let cancelHit = FSEvent(eventCategory: .User_Engagement, eventAction: "cta_cancelBasket_hit")
        Flagship.sharedInstance.sendHit(cancelHit)
        
    }
    
}






/// Product class
public class FSProduct {
    
    var name:String!
    var imageString:String!
    var size:String!
    var price:String!

    
    init(_ name:String, _ photoName:String, _ size:String, _ price:String) {
        
        self.name = name
        self.imageString = photoName
        self.size = size
        self.price = price
    }
}
