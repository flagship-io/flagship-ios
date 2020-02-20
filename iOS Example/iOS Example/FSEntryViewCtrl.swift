//
//  FSEntryViewCtrl.swift
//  iOS Example
//
//  Created by Adel on 20/01/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSEntryViewCtrl: UIViewController {
    
    
    @IBOutlet var signInBtn:UIButton!
    @IBOutlet var logInBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let loadView = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 100, height: 100))
        loadView.center = self.view.center
        loadView.color = .red
        loadView.startAnimating()
        self.view.addSubview(loadView)
        // Reset vid
        Flagship.sharedInstance.resetUserIdFlagShip()
        
        
        Flagship.sharedInstance.updateContextWithPreConfiguredKeys(.FIRST_TIME_INIT, value: "rr", sync: nil)
        
        /// Set context isVip to true
        Flagship.sharedInstance.context("isVip", true)
        /// Start The sdk
        
        Flagship.sharedInstance.updateContext(["sdk_city":"panama", "isVip":false, "basketNumber":100], sync: nil)
        
      
        
        Flagship.sharedInstance.startFlagShipWithMode(environmentId: "bkk9glocmjcg0vtmdlng", nil , .BUCKETING) { (result) in
            
            if result == .Ready{
                
                DispatchQueue.main.async {
                    
                    loadView.stopAnimating()
                    self.logInBtn.isHidden  = false
                    self.signInBtn.isHidden = false
                }
                
            }else{
                
            }
        }
        
    }
    
    
    
    
    @IBAction func onShowLoginScreen(){
        self.performSegue(withIdentifier: "showLoginScreen", sender:nil)
    }
    
}
