//
//  ViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 24/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import FlagShip

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var loginTextField:UITextField!
    
    @IBOutlet var loginBtn:UIButton!
    
    // AB Test Button
    @IBOutlet var abTestBtn:UIButton!

    // Perso Test
    @IBOutlet var persoBtn:UIButton!

    // Toggle Test
    @IBOutlet var toggleBtn:UIButton!

    @IBOutlet var vipToggle:UISwitch!
    
    
    @IBOutlet var newUserToggle:UISwitch!

    
    @IBOutlet var sessionNumberFiled:UITextField!

    
    // Is Vip user
    var isVipUser:Bool = false
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        
        //Round button login
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.layer.masksToBounds = true
        
        // Add gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        // Set the vip user
        isVipUser = vipToggle.isOn
    }
    
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
    }
    
    
    
    
    
    // Log with FlagShip
    @IBAction func logInwithFlagShip(){
        
        // Update Context
        ABFlagShip.sharedInstance.context("isVipUser",vipToggle.isOn)
        ABFlagShip.sharedInstance.context("newUser",newUserToggle.isOn)
        
        // Start FlagShip Sdk
        ABFlagShip.sharedInstance.startFlagShip(self.loginTextField.text) { (state) in
            // Launch the app with user context
            
            if state == .Ready {
                DispatchQueue.main.async {
                    self.abTestBtn.isEnabled =  true
                    self.toggleBtn.isEnabled = true
                }
            }
        }
        
        
    }
    
    
    // show AB test
    @IBAction func showABTest(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "showABtest", sender:nil)
        }
    }
    
    
    // Show Vip Test
    @IBAction func showVipTest(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "onShowVip", sender:nil)
        }
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "onShowVip"{
            
            let basketCtrl = segue.destination as! FSCartViewController
            basketCtrl.isNewUser = newUserToggle.isOn
        }
    }
}

