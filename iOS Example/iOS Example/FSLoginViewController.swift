
//
//  FSLoginViewController.swift
//  iOS Example
//
//  Created by Adel on 20/01/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit

/// Import Lib
import Flagship

class FSLoginViewController: UIViewController, UITextFieldDelegate {
    
    /// Login
    @IBOutlet var loginTextField:UITextField!
    /// Password
    @IBOutlet var passwordTestField:UITextField!
    /// Login btn
    @IBOutlet var loginBtn:UIButton!


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Round button login
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.layer.masksToBounds = true
        
        
        // Add gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
    }
    
    

    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
        passwordTestField.resignFirstResponder()
    }
    
    
 /// On Click Login
  @IBAction func onClickLogin(){
    
    Flagship.sharedInstance.updateContext("isVip", true)
    Flagship.sharedInstance.updateContext("Number_Key", 200)
    Flagship.sharedInstance.updateContext("Boolean_Key", true)
    Flagship.sharedInstance.updateContext("String_Key", "june")


    
    /// Start Flagship
    
    
    Flagship.sharedInstance.start(envId:"bkk9glocmjcg0vtmdlo0", apiKey: "j2jL0rzlgVaODLw2Cl4JC3f4MflKrMgIaQOENv36", visitorId: nil, config: FSConfig(.DECISION_API)) { (result) in
        
        
        /// When the sdk is ready ...
        if result == .Ready{
            
            
            Flagship.sharedInstance.activateModification(key: "complex")
            
            Flagship.sharedInstance.activateModification(key: "alias")
            
            Flagship.sharedInstance.activateModification(key: "array")
            
            let result = Flagship.sharedInstance.getModification("complex", defaultDico:[:])
            

            let resultArray = Flagship.sharedInstance.getModification("array", defaultArray: [])
            


             DispatchQueue.main.async {
                 
                 self.performSegue(withIdentifier: "onClickLogin", sender: nil)
                 
             }
              
          }else{
              /// Manage Error
            
            print("error on start")
            
          }
        
    }
    
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
