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
    @IBOutlet var jeanBtn:UIButton!
    @IBOutlet var shoesBtn:UIButton!
    @IBOutlet var shirtBtn:UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        
  
        // Get backgroud color
        self.view.backgroundColor = UIColor(hexString:FlagShip.sharedInstance.getModification("backgroundColor", defaultString: "#ffffff", activate: false), alpha: 1.0)
        
        self.jeanBtn.backgroundColor = UIColor(hexString:FlagShip.sharedInstance.getModification("btn-color", defaultString: "#ffffff", activate: false), alpha: 1.0)
        
        
        self.shoesBtn.backgroundColor = UIColor(hexString:FlagShip.sharedInstance.getModification("btn-color", defaultString: "#ffffff", activate: false), alpha: 1.0)
        
        
        self.shirtBtn.backgroundColor = UIColor(hexString:FlagShip.sharedInstance.getModification("btn-color", defaultString: "#ffffff", activate: false), alpha: 1.0)

       }
    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
    }

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

