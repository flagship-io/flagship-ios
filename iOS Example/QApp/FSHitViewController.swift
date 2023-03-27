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
        eventHitBtn.isEnabled = false
        transactiontHitBtn.isEnabled = false
        
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
        //  if let input = interfaceNameFiled!.text {
        //   if input.count > 2 {
        for index in 0...2 {
            let nameScreen = String(format: "testScreen_%d", index)
            Flagship.sharedInstance.sharedVisitor?.sendHit(FSScreen(nameScreen))
        }
        
        for indexBis in 0...2 {
            let nameEvent = String(format: "event_%d", indexBis)
            
            let event = FSEvent(eventCategory: .Action_Tracking, eventAction: nameEvent)
            event.label = "label_event"
            event.userIp = "192.168.1.0"
            event.userLanguage = "FR"
            Flagship.sharedInstance.sharedVisitor?.sendHit(event)
        }
        
        for indexBis in 0...2 {
            let nameTransac = String(format: "transac_%d", indexBis)
            
            let eventTransac = FSTransaction(transactionId: "id_transac", affiliation: nameTransac)
            eventTransac.userIp = "192.168.1.0"
            eventTransac.userLanguage = "FR"
            eventTransac.itemCount = 12
            eventTransac.shipping = 50
            eventTransac.tax = 0.5
            Flagship.sharedInstance.sharedVisitor?.sendHit(eventTransac)
        }
    }
    
    /// Send Event hit
    
    @IBAction func onClickEventHit() {
        if let input = eventAction!.text {
            if input.count > 2 {
                let type: FSCategoryEvent = typeEventSwitch.isOn ? .Action_Tracking : .User_Engagement
                let eventToSend = FSEvent(eventCategory: type, eventAction: input)
                eventToSend.eventValue = UInt(eventValueField.text ?? "0")
                Flagship.sharedInstance.sharedVisitor?.sendHit(eventToSend)
                showPopUpMessage("Event name: \(input)")
            }
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
                
                /// Send hit transaction
                Flagship.sharedInstance.sharedVisitor?.sendHit(hitTransac)
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
            
            return (string.rangeOfCharacter(from: allowedChar) == nil)
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
