
//
//  FSLoginViewController.swift
//  iOS Example
//
//  Created by Adel on 20/01/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import FlagShip

class FSLoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var loginTextField:UITextField!
    
    @IBOutlet var passwordTestField:UITextField!

    
    @IBOutlet var loginBtn:UIButton!
    
    @IBOutlet var faceBookBtn:UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Round button login
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.layer.masksToBounds = true
        
        faceBookBtn.layer.cornerRadius = loginBtn.frame.height/2
        faceBookBtn.layer.masksToBounds = true
        
        // Add gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        
        
        /// test
        
        FlagShip.sharedInstance.getModification("arrayValues", defaulfloat: 2, activate: false)
        
        
        
        
        /// Activate manually the modification
        
        FlagShip.sharedInstance.getModification("cta_value", defaultInt: 0)
        
        /// Actiavte
        
        FlagShip.sharedInstance.activateModification(key: "cta_value")
        
        
        /// Update the context when basket value change
        FlagShip.sharedInstance.updateContext(["basketValue":120]) { (result) in
            
            if result == .Updated{
                
                // Update the ui for users that have basket over or equal 100
                if (FlagShip.sharedInstance.getModification("freeDelivery", defaultBool: false, activate: true)){
                    
                    DispatchQueue.main.async {
                        
                        /// Show your message for free delivery
                        
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
    }
    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
        passwordTestField.resignFirstResponder()
    }
    
    @IBAction func onClickLogin(){
        
        self.performSegue(withIdentifier: "onClickLogin", sender: nil)
        
        
    }
    
    
    @IBAction func onCancel(){
        
        self.dismiss(animated: true, completion:nil)
    }
    
    
    // Delegate textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            if updatedText.count > 3{
                
                loginBtn.isEnabled = true
            }else{
                
                loginBtn.isEnabled = false
            }
        }
        
        return true
    }
    
    
    
}
