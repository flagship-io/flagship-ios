//
//  FSHitViewController.swift
//  QApp
//
//  Created by Adel on 26/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSHitViewController: UIViewController,UITextFieldDelegate {
    
    /// Page
    @IBOutlet weak var interfaceNameFiled: UITextField!
    
    @IBOutlet weak var pageHitBtn: UIButton!

    
    /// Event
    @IBOutlet weak var eventAction: UITextField!
    
    @IBOutlet weak var typeEventSwitch: UISwitch!
    
    @IBOutlet weak var eventHitBtn: UIButton!
    
    @IBOutlet weak var labelSwitch: UILabel!
    
    
    /// Transaction
    
    @IBOutlet weak var transactiontHitBtn: UIButton!
    
    @IBOutlet weak var idTransacField: UITextField!
    
    @IBOutlet weak var affiliationField: UITextField!
    
    @IBOutlet weak var revenueField: UITextField!
    
    @IBOutlet weak var shippingField: UITextField!
    
    @IBOutlet weak var taxField: UITextField!
    
    @IBOutlet weak var currencyField: UITextField!
    
    @IBOutlet weak var couponCodeField: UITextField!
    
    @IBOutlet weak var paymentMethodField: UITextField!
    
    @IBOutlet weak var shippingMethodField: UITextField!
    
    @IBOutlet weak var itemCountField: UITextField!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
    
    
     

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        /// Disable the buttons
        pageHitBtn.isEnabled = false
        eventHitBtn.isEnabled = false
        transactiontHitBtn.isEnabled = false
        
        FSCTools.roundButton(pageHitBtn)
        FSCTools.roundButton(eventHitBtn)
        FSCTools.roundButton(transactiontHitBtn)


        
    }
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
    }
    
    
    //// Send The hit page
    @IBAction func onClickPageHit(){
        
        if let input = interfaceNameFiled!.text{
            
            if input.count > 2{
                
                Flagship.sharedInstance.sendHit(FSPage(input))
                showPopUpMessage("Page name: \(input)")

            }
        }
    }
    
    
    
    /// Send Event hit
    
    @IBAction func onClickEventHit(){
        
        if let input = eventAction!.text{
            
            if input.count > 2{
                
                let type:FSCategoryEvent = typeEventSwitch.isOn ? .Action_Tracking : .User_Engagement
                Flagship.sharedInstance.sendHit(FSEvent(eventCategory:type, eventAction: input))
                showPopUpMessage("Event name: \(input)")
            }
        }
    }
    
    /// Send Transaction
    
    @IBAction func onClickTransactionHit(){
        
        if let input = idTransacField!.text  {
            
            if let inputName = affiliationField!.text{
                
                let hitTransac = FSTransaction(transactionId:input, affiliation:inputName)
                
                /// revenue
                if let inputRevenue = revenueField!.text{
                    
                    hitTransac.revenue = NSNumber(value: Int(String(format: "%@", inputRevenue)) ?? 0)

                }
                /// shipping
                if let inputShipping = shippingField.text{
                    
                    hitTransac.shipping = NSNumber(value: Int(String(format: "%@", inputShipping)) ?? 0)

                }
                /// tax
                if let inputTax = taxField.text{
                    
                    hitTransac.tax = NSNumber(value: Int(String(format: "%@", inputTax)) ?? 0)
                }
                /// currency
                if let inputCurrency = currencyField.text{
                    
                    hitTransac.currency = inputCurrency
                }
                /// couponCode
                if let inputCoupon = couponCodeField.text{
                    
                    hitTransac.couponCode = inputCoupon
                }
                /// paymentMethod
                if let inputPay = paymentMethodField.text{
                    
                    hitTransac.paymentMethod = inputPay
                }
                /// shippingMethod
                if let inputShipMethode = shippingMethodField.text{
                    
                    hitTransac.shippingMethod = inputShipMethode
                }
                //// items
                
                hitTransac.itemCount = 0
                
                /// Send hit transaction
                Flagship.sharedInstance.sendHit(hitTransac)
                showPopUpMessage("Transaction name: \(inputName)")

            }
            

        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        
        if textField.tag == 111 {
            
            if updatedText.count > 2 {
                
                pageHitBtn.isEnabled = true
            }else{
                pageHitBtn.isEnabled = false
            }
        }else if textField.tag == 222{
            
            if updatedText.count > 2 {
                
                eventHitBtn.isEnabled = true
            }else{
                eventHitBtn.isEnabled = false
            }
        }else if (textField.tag == 333 ){
            
            if updatedText.count > 2 {
                
                transactiontHitBtn.isEnabled = true
            }else{
                transactiontHitBtn.isEnabled = false
            }
        }
        
        /// if the tag is over 400 ===> only number field
        if textField.tag > 400 {
            
            let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
            
            return (string.rangeOfCharacter(from: invalidCharacters) == nil)
                
        }
        
        return true
    }
    
    
    @IBAction func onChangeSwitch(){
        
    let typeString = typeEventSwitch.isOn ? FSCategoryEvent.Action_Tracking.categoryString :  FSCategoryEvent.User_Engagement.categoryString
        
        DispatchQueue.main.async {
            
            self.labelSwitch.text = typeString
        }
    }
    
    
    
    private func showPopUpMessage(_ message:String){
        let msg = String(format: "%@",message )
        let alertCtrl = UIAlertController(title: "HIT", message:msg, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel,handler: nil))
        self.present(alertCtrl, animated: true, completion: nil)
    }

}
