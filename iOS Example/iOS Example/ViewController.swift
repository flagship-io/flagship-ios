//
//  ViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 24/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
//import FlagShip
import Flagship
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
        
        
        

       }
    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
    }
    
    
    // Log with FlagShip
//    @IBAction func logInwithFlagShip(){
//
//
//
//
//
//
//        // Update Context
//        FlagShip.sharedInstance.context("isVipUser",vipToggle.isOn)
//        FlagShip.sharedInstance.context("newUser",newUserToggle.isOn)
//
//        /// Groupe 1
//        FlagShip.sharedInstance.context("cond_1", "val_2")
//        FlagShip.sharedInstance.context("cond_2", 1)
//        FlagShip.sharedInstance.context("cond_3", true)
//        FlagShip.sharedInstance.context("floatKay", 3.14)
//
//        /// groupe 2
//
//       // ABFlagShip.sharedInstance.context("basketNumber", 200)
//        FlagShip.sharedInstance.context("basketNumber", 123)
//
//        /// Groupe 3
//        FlagShip.sharedInstance.context("cond_10", 111)   // => 4
//        FlagShip.sharedInstance.context("cond_11", 7)  // =<5
//
//        /// groupe 4
//        FlagShip.sharedInstance.context("cond_4","val_41")   // not val_4
//        FlagShip.sharedInstance.context("cond_5", "jeans...")   // contain jeans
//        FlagShip.sharedInstance.context("cond_6", 13)   // > 12
//        FlagShip.sharedInstance.context("cond_7", false)   // not true
//        FlagShip.sharedInstance.context("cond_8", "sh&oes")   // => does  not contain shoes
//
//
//
//        /// Set Ip Adress
//
//        FlagShip.sharedInstance.updateContextWithPreConfiguredKeys(.IP, value: "2001:0db8:0000:0000:0000:ff00:0042:7879", sync: nil)
//
//        // ABFlagShip.sharedInstance.updateContextWithPreConfiguredKeys(.IP, value: "254.233.221.3", sync: nil)
//
//        /// reset the flagship id
//        FlagShip.sharedInstance.resetUserIdFlagShip()
//
//
//        // Start FlagShip
//        FlagShip.sharedInstance.startFlagShipWithMode(loginTextField.text, .BUCKETING ) { (state) in
//
//                        // The state is ready , you can now use the FlagShip
//                        if state == .Ready ||  state == .Disabled {
//                            DispatchQueue.main.async {
//                                self.abTestBtn.isEnabled =  true
//                                self.toggleBtn.isEnabled =  true
//                            }
//                        }
//        }
//
//    }
    



    // Show AB test  (Store Screen)
    @IBAction func showShoesScreen(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "showShoesStore", sender:nil)
        }
    }
    
    
    // Show Vip Test  (Basket Screen)
    @IBAction func showBasketScreen(){
        
        DispatchQueue.main.async {
            
            self.performSegue(withIdentifier: "showBasket", sender:nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showBasket"{
            let basketCtrl = segue.destination as! FSCartViewController
         }
    }
    
    
    @IBAction func onCancel(){
        self.dismiss(animated: true , completion: nil)
    }
}

