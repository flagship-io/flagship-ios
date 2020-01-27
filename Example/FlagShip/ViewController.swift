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
   // @IBOutlet var persoBtn:UIButton!

    // Toggle Test
    @IBOutlet var toggleBtn:UIButton!

    // Vip Switch
    @IBOutlet var vipToggle:UISwitch!
    
    // Is new user switch
    @IBOutlet var newUserToggle:UISwitch!
    
    
    
    
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
     }
    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
    }
    
    
    // Log with FlagShip
    @IBAction func logInwithFlagShip(){
        
        // Update Context
        ABFlagShip.sharedInstance.context("isVipUser",vipToggle.isOn)
        ABFlagShip.sharedInstance.context("newUser",newUserToggle.isOn)
        
        // bkk9glocmjcg0vtmdlng
        
   
        
        // Start FlagShip Sdk
        ABFlagShip.sharedInstance.startFlagShip(environmentId:"bkk9glocmjcg0vtmdlng", "    ") { (state) in
            
            // The state is ready , you can now use the FlagShip
            if state == .Ready {
                DispatchQueue.main.async {
                    self.abTestBtn.isEnabled =  true
                    self.toggleBtn.isEnabled = true
                }
            }
        }
    }
    
    
    
    
    // Show AB test  (Store Screen)
    @IBAction func showStoreScreen(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "showStore", sender:nil)
        }
    }
    
    
    // Show Vip Test  (Basket Screen)
    @IBAction func showBasketScreen(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "showBasket", sender:nil)
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
        
        if segue.identifier == "showBasket"{
            
            let basketCtrl = segue.destination as! FSCartViewController
            basketCtrl.isNewUser = newUserToggle.isOn
        }
    }
}

