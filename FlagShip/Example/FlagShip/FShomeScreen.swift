//
//  FShomeScreen.swift
//  Flagship_Example
//
//  Created by Adel on 06/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import FlagShip

class FShomeScreen: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var startButton:UIButton!
    
    @IBOutlet var updateButton:UIButton!
    
    //// Context Values
    
    var stringValue:String = ""
    
    @IBOutlet var stringValueTextFiled:UITextField!

    
    var numberValue:Double! = 0.0
    @IBOutlet var numberValueTextField:UITextField!

    ///


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // String Label
        stringValueTextFiled.tag = 100
        // Nimber Label
        numberValueTextField.tag = 200
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(onTap(_:)) ))

    }
    
    
    @objc func onTap(_ gest:UITapGestureRecognizer){
        
        view.endEditing(true)
    }
    
    @IBAction func onClickStart(){
        
        self.performSegue(withIdentifier: "onStart", sender: nil)
    }
    
    
    @IBAction func updateContext(){
        
        self.startButton.setTitle("Not Ready", for: .normal)
        self.startButton.backgroundColor = .orange
        let loadingActivity:UIActivityIndicatorView =  UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: updateButton.frame.width, height: updateButton.frame.height))
        loadingActivity.startAnimating()
        self.startButton.addSubview(loadingActivity)
        
        ABFlagShip.sharedInstance.context("basketNumber", numberValue)
        ABFlagShip.sharedInstance.context("isVipUser", true)
        ABFlagShip.sharedInstance.updateContext(<#T##contextvalues: Dictionary<String, Any>##Dictionary<String, Any>#>, sync: <#T##((FlagshipState) -> Void)?##((FlagshipState) -> Void)?##(FlagshipState) -> Void#>)
        
        // Start FlagShip  /// vid en option 
        ABFlagShip.sharedInstance.startFlagShip("adel") { (state) in
            
            DispatchQueue.main.async {
                
                self.startButton.setTitle("Ready To Use", for: .normal)
                
                loadingActivity.stopAnimating()
                loadingActivity.removeFromSuperview()
                self.startButton.isEnabled = true
                self.startButton.backgroundColor = .green
            }
        }
    }
    
    
    
    
    func readValueContext(){
        
        if (numberValueTextField.text != ""){
            
            
        }
    }
    
    
    //// Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
       
         /// Here the number
        if textField.tag == 200{
            
            numberValue = Double(updatedText)
            
        }else{ // Otherwise
            
            stringValue = updatedText
            
            }
        }
        
        return true
    }
    
    
    
    @IBAction func goToBannerTest(){
        
        self.performSegue(withIdentifier: "goToBannerTest", sender: nil)
    }
    
    
    @IBAction func onSwitch(_ sender: Any) {
        
        let togSwitch:UISwitch = sender as! UISwitch
        
        ABFlagShip.sharedInstance.disabledSdk = !togSwitch.isOn
        
        
    }
    
    
    
    
}
