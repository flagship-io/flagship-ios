
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
    
    
    var showView:Bool = true
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Round button login
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.layer.masksToBounds = true
        
        faceBookBtn.layer.cornerRadius = loginBtn.frame.height/2
        faceBookBtn.layer.masksToBounds = true
        
        // Add gesture
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        
        // notification download _FSBucketing
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveNotification), name: NSNotification.Name("Download_Script"), object: nil)
    }
    
    
    @objc func onReceiveNotification(){
        
        self.showView = false
        DispatchQueue.main.async {
            
            let alert304 = UIAlertController(title: "Bucketing", message: "Download the bucketing file", preferredStyle: .alert)
            
            alert304.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
                
                
                    DispatchQueue.main.async {
                         
                         self.performSegue(withIdentifier: "onClickLogin", sender: nil)
                         
                     }
            })
            self.present(alert304, animated: true, completion:nil)
        }

    }
    
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        loginTextField.resignFirstResponder()
        passwordTestField.resignFirstResponder()
    }
    
    
 /// On Click Login
  @IBAction func onClickLogin(){
      
     // Flagship.sharedInstance.context("isVip", true)
      Flagship.sharedInstance.start(environmentId: "bkk9glocmjcg0vtmdlng", loginTextField.text, .DECISION_API) { (result) in
          
          
          if result == .Ready{
              
              if self.showView{
                  
                  DispatchQueue.main.async {
                       
                       self.performSegue(withIdentifier: "onClickLogin", sender: nil)
                       
                   }
                  
              }
              
          }else{
              
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
    
    
    
    func readBucketFromCache(){
        
        if var url:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
            // add file name
            url.appendPathComponent("bucket.json")
            
            if (FileManager.default.fileExists(atPath: url.path) == true){
                
                do{
                    
                    let attributes  = try FileManager.default.attributesOfItem(atPath: url.path)
                    
                    print(attributes[FileAttributeKey.modificationDate])
 
                 }catch{
                    
                    
                }
                
            }else{
                
                 
            }
        }
        
    }

}
