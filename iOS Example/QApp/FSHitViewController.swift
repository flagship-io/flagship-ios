//
//  FSHitViewController.swift
//  QApp
//
//  Created by Adel on 26/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Flagship
import UIKit

class FSHitViewController: UIViewController, UITextFieldDelegate {
    /// Page
    @IBOutlet var interfaceNameFiled: UITextField!
    
    @IBOutlet var pageHitBtn: UIButton!

    /// Event
    @IBOutlet var eventAction: UITextField!
    
    @IBOutlet var typeEventSwitch: UISwitch!
    
    @IBOutlet var eventHitBtn: UIButton!
    
    @IBOutlet var labelSwitch: UILabel!
    
    @IBOutlet var eventValueField: UITextField!

    /// Transaction
    
    @IBOutlet var transactiontHitBtn: UIButton!
    
    @IBOutlet var idTransacField: UITextField!
    
    @IBOutlet var affiliationField: UITextField!
    
    @IBOutlet var revenueField: UITextField!
    
    @IBOutlet var shippingField: UITextField!
    
    @IBOutlet var taxField: UITextField!
    
    @IBOutlet var currencyField: UITextField!
    
    @IBOutlet var couponCodeField: UITextField!
    
    @IBOutlet var paymentMethodField: UITextField!
    
    @IBOutlet var shippingMethodField: UITextField!
    
    @IBOutlet var itemCountField: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        /// Disable the buttons
        //  pageHitBtn.isEnabled = false
        // eventHitBtn.isEnabled = false
        // transactiontHitBtn.isEnabled = false
        
        FSCTools.roundButton(pageHitBtn)
        FSCTools.roundButton(eventHitBtn)
        FSCTools.roundButton(transactiontHitBtn)
    }
    
    // Hide KeyBoard
    @objc func hideKeyBoard() {
        view.endEditing(true)
    }
    
    //// Send The hit page
    @IBAction func onClickPageHit() {
        if let input = interfaceNameFiled!.text {
            Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen(input))
        }
        
        // Send Pageview
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSPage("https://nextjs-abtasty.vercel.app/"))
    }
    
    /// Send Event hit
    @IBAction func onClickEventHit() {
        if let input = eventAction!.text {
            //  if input.count > 2 {
            let type: FSCategoryEvent = typeEventSwitch.isOn ? .Action_Tracking : .User_Engagement
            let eventToSend = FSEvent(eventCategory: type, eventAction: input)
            eventToSend.eventValue = UInt(eventValueField.text ?? "0")
            eventToSend.location = "screen_event"
            
            Flagship.sharedInstance.sharedVisitor?.sendHit(eventToSend)
            showPopUpMessage("Event name: \(input)")
            // }
        }
    }
    
    /// Send Transaction
    
    @IBAction func onClickTransactionHit() {
        if let input = idTransacField!.text {
            if let inputName = affiliationField!.text {
                let hitTransac = FSTransaction(transactionId: input, affiliation: inputName)
                
                /// revenue
                if let inputRevenue = revenueField!.text {
                    hitTransac.revenue = NSNumber(value: Int(String(format: "%@", inputRevenue)) ?? 0)
                }
                /// shipping
                if let inputShipping = shippingField.text {
                    hitTransac.shipping = NSNumber(value: Int(String(format: "%@", inputShipping)) ?? 0)
                }
                /// tax
                if let inputTax = taxField.text {
                    hitTransac.tax = NSNumber(value: Int(String(format: "%@", inputTax)) ?? 0)
                }
                /// currency
                if let inputCurrency = currencyField.text {
                    hitTransac.currency = inputCurrency
                }
                /// couponCode
                if let inputCoupon = couponCodeField.text {
                    hitTransac.couponCode = inputCoupon
                }
                /// paymentMethod
                if let inputPay = paymentMethodField.text {
                    hitTransac.paymentMethod = inputPay
                }
                /// shippingMethod
                if let inputShipMethode = shippingMethodField.text {
                    hitTransac.shippingMethod = inputShipMethode
                }
                //// items
                
                hitTransac.itemCount = 0
                /// Hit transaction
                hitTransac.location = "screen_transaction"
                
                /// Send hit transaction
                Flagship.sharedInstance.sharedVisitor?.sendHit(hitTransac)
                showPopUpMessage("Transaction name: \(inputName)")
            }
        }
        
        // add item
        let t = FSItem(transactionId: "testId", name: "itemName", code: "codeItme")
        
        t.price = 12
        t.quantity = 2
        t.location = "screen_transaction"
        
        Flagship.sharedInstance.sharedVisitor?.sendHit(t)
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSPage("pageView"))
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
            } else {
                pageHitBtn.isEnabled = false
            }
        } else if textField.tag == 222 {
            if updatedText.count > 2 {
                eventHitBtn.isEnabled = true
            } else {
                eventHitBtn.isEnabled = false
            }
        } else if textField.tag == 333 {
            if updatedText.count > 2 {
                transactiontHitBtn.isEnabled = true
            } else {
                transactiontHitBtn.isEnabled = false
            }
        }
        
        /// if the tag is over 400 ===> only number field
        if textField.tag > 400 {
            let allowedChar = CharacterSet(charactersIn: "0123456789").inverted
            
            return string.rangeOfCharacter(from: allowedChar) == nil
        }
        
        return true
    }
    
    @IBAction func onChangeSwitch() {
        let typeString = typeEventSwitch.isOn ? FSCategoryEvent.Action_Tracking.categoryString : FSCategoryEvent.User_Engagement.categoryString
        
        DispatchQueue.main.async {
            self.labelSwitch.text = typeString
        }
    }
    
    private func showPopUpMessage(_ message: String) {
        let msg = String(format: "%@", message)
        let alertCtrl = UIAlertController(title: "HIT", message: msg, preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertCtrl, animated: true, completion: nil)
    }
}
