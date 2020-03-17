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
        
        
        /// Set context isVip to true
        Flagship.sharedInstance.context("isVip", true)
        /// Set The sdk context
        Flagship.sharedInstance.updateContext(["sdk_city":"panama", "isVip":false, "basketNumber":100], sync: nil)
        
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onFinish), userInfo: nil, repeats: false)
        
    }
    
    
    @objc func onFinish(){
        
        self.performSegue(withIdentifier: "showLoginScreen", sender:nil)
        
    }
    
    
    
    
    
    
    @IBAction func onShowLoginScreen(){
        self.performSegue(withIdentifier: "showLoginScreen", sender:nil)
    }
    
    
    
    func docMySelf(){
        
        /// Set the context isVip to true
        Flagship.sharedInstance.updateContext("isVip", true)
        
        
        
        ///update context with pre configured key
        
        /// Set Region
        Flagship.sharedInstance.updateContext(configuredKey: PresetContext.LOCATION_REGION, value: "ile de france")
        
        /// Set Country
        Flagship.sharedInstance.updateContext(configuredKey: PresetContext.LOCATION_COUNTRY, value: "FRANCE")

        
        
        /// Add several pre configured key using the dictionary
        Flagship.sharedInstance.updateContext([PresetContext.LOCATION_CITY.rawValue:"paris",
                                              PresetContext.LOCATION_COUNTRY.rawValue:"France",
                                              PresetContext.LOCATION_REGION.rawValue:"ile de france"])
        
  
        
        /// Update context with "basketValue" = 120
        Flagship.sharedInstance.updateContext("basketValue", 120)
        
        /// Synchronize campaigns
        Flagship.sharedInstance.synchronizeModifications { (result) in
            
            if result == .Updated{
                
                // Update the UI for users that have basket over or equal 100
                if (Flagship.sharedInstance.getModification("freeDelivery", defaultBool: false, activate: true)){
                    
                    DispatchQueue.main.async {
                        
                        /// Show your message for free delivery
                        
                    }
                }
            }
        }
        
        
        
        /// Get "cta_text"
        let title = Flagship.sharedInstance.getModification("cta_text", defaultString:"default", activate: true)
        
        
        
        
        /// get "cta_vallue"
        let value = Flagship.sharedInstance.getModification("cta_value", defaultInt: 0)
        
        /// Activate Manually
        Flagship.sharedInstance.activateModification(key: "cta_value")
        
        
        
        
        
        /// get "isHidden"
        let isTrue = Flagship.sharedInstance.getModification("isHidden", defaultBool: false, activate: true)
        
        
        
        
        
        print(title)

        print(value)
        print(isTrue)

        
        
        
        
    }
    
}
