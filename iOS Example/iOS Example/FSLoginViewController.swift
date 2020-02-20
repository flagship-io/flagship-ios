
//
//  FSLoginViewController.swift
//  iOS Example
//
//  Created by Adel on 20/01/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSLoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var loginTextField:UITextField!
    
    @IBOutlet var passwordTestField:UITextField!

    
    @IBOutlet var loginBtn:UIButton!
    
    @IBOutlet var faceBookBtn:UIButton!
    
    @IBOutlet var parrainageBtn:UIButton!

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Round button login
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.layer.masksToBounds = true
        
        faceBookBtn.layer.cornerRadius = loginBtn.frame.height/2
        faceBookBtn.layer.masksToBounds = true
        
        // Add gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        /// Display Feature 1
        
        if (Flagship.sharedInstance.getModification("Feature1", defaultBool: false)){
            
            parrainageBtn.layer.cornerRadius = loginBtn.frame.height/2
            parrainageBtn.layer.masksToBounds = true
            parrainageBtn.isHidden = false
            
            Flagship.sharedInstance.activateModification(key: "Feature1")
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
    
    
    /// Send action on click parainage
    @IBAction func onClikcParrainage(){
        
        Flagship.sharedInstance.sendTracking(FSEventTrack(eventCategory: .Action_Tracking, eventAction: "parrainage_kpi"))
    }
}
