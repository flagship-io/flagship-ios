//
//  FSCartViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 25/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import FlagShip

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
        
        
        
        
        if (ABFlagShip.sharedInstance.getModification("isVip", defaultBool:false, activate: true)){
            
            priceDelivery.text = "Free for vip"
            
        }else{
            
            priceDelivery.text = String(format: "%.01f EUR ", feeDelivery)
        }
        
        
        
        // Send event page
        let eventPage:FSPageTrack = FSPageTrack("basketScreen")
        ABFlagShip.sharedInstance.sendTracking(eventPage)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if (isNewUser){
            
            let msg = ABFlagShip.sharedInstance.getModification("persoMessage", defaultString: "Welcome", activate: true)
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
        
        let transacEvent:FSTransactionTrack = FSTransactionTrack(transactionId: "123455", affiliation: "demotransac")
        transacEvent.currency = "EUR"
        transacEvent.itemCount = 2
        transacEvent.paymentMethod = "Ecard"
        ABFlagShip.sharedInstance.sendTracking(transacEvent)
    }
    
    
    
    @IBAction func onCancel(){
        
        let cancelEvent:FSEventTrack = FSEventTrack(eventCategory: .User_Engagement, eventAction: "cta_cancelBasket")
        ABFlagShip.sharedInstance.sendTracking(cancelEvent)
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
