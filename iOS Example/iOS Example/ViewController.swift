//
//  ViewController.swift
//  FlagShipDemo
//
//  Created by Adel on 24/09/2019.
//  Copyright © 2019 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    /// First Button Button
    @IBOutlet var firstButton:UIButton!
    
    /// Second Button Button
    @IBOutlet var secondButton:UIButton!
    
    /// Third Button Button
    @IBOutlet var thirdButton:UIButton!

    
    /// Parrainage
    @IBOutlet var parrainageBtn:UIButton!
    
    
    /// Switch
    
    @IBOutlet var vipSwitch:UISwitch!
    
    /// Style bar
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .default
    }
    @IBOutlet var jeanBtn:UIButton!
    @IBOutlet var shoesBtn:UIButton!
    @IBOutlet var shirtBtn:UIButton!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        /// Create object configuration
//        let fsConfig = FSConfig(.DECISION_API, apiTimeout: 0.2)
//        
//        /// Start the SDK
//        Flagship.sharedInstance.start(envId:"your envId", apiKey: "your apiKey", visitorId:"visitorId", config:fsConfig){ (result) in
//            
//            if result == .Ready {
//              DispatchQueue.main.async {
//
//                /// Update UI
//              }
//
//              }else{
//
//                /// An error occurs or the SDK is disabled
//              }
//        }
//        
  
        
        
        
         parrainageBtn.isHidden = false
        
        /// Get Color for background defined in dashboard flagship
        let colorHexTitle =  Flagship.sharedInstance.getModification("backgroundColor", defaultString: "#b6fcd5", activate: true)
       
        /// Activate modification to tell Flagship that the user has seen this specific variation
        Flagship.sharedInstance.activateModification(key: "backgroundColor")
        self.view.backgroundColor = UIColor(hexString: colorHexTitle, alpha: 1.0)
 
        /// Get color for button
        
        self.firstButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)
        
 
        self.secondButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)
        
        self.thirdButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)
        
        self.thirdButton.setTitle(Flagship.sharedInstance.getModification("ctxKeyString", defaultString:"None", activate: true), for: .normal)
        
        
        
     //   let list = Flagship.sharedInstance.getModification("list", defaultArray: [], activate: true)

        
        
        
        
        // The get modificationInfo return [String:String]? // { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”}
        
        let inofs = Flagship.sharedInstance.getModificationInfo(key:"btn-color")
        
        if let infoCampaign = inofs {
            
            /// Retreive the campaignId
            let campaignId = infoCampaign["campaignId"]    as? String  ?? ""
            
            /// Retreive the variationGroupId
            let variationGroupId = infoCampaign["variationGroupId"]    as? String ?? ""
            
            /// Retreive the variationId
            let variationId = infoCampaign["variationId"]    as? String  ?? ""
            
            let isReference = infoCampaign["isReference"]    as? Bool  ?? false
            
            if (isReference){
                
                print("Reference")
            }

            
            
            print(campaignId   + variationId   + variationGroupId  )
            
        }else {
            
            print("The key modification don't exist")
        }
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
    
    @IBAction func onCancel(){
        self.dismiss(animated: true , completion: nil)
    }
    
    /// Display Feature 1
    
    func displayFeature1(){
        
        /// Display Feature 1 if available /// Feature 1 is defined from dashBoard
        if (Flagship.sharedInstance.getModification("Feature1", defaultBool: false)){
            
            parrainageBtn.layer.cornerRadius = parrainageBtn.frame.height/2
            parrainageBtn.layer.masksToBounds = true
            parrainageBtn.isHidden = false
            
            Flagship.sharedInstance.activateModification(key: "Feature1")
        }
    }
    
    
    
    /// Send KPI  "parrainage_kpi" when click on parrainage button
    @IBAction func onClikcParrainage(){
        
        Flagship.sharedInstance.sendHit(FSEvent(eventCategory: .Action_Tracking, eventAction: "kpi_v2"))
        
        Flagship.sharedInstance.sendHit(FSEvent(eventCategory: .User_Engagement, eventAction: "kpi_v2_Engagemen"))

        Flagship.sharedInstance.sendHit(FSTransaction(transactionId: "idV2", affiliation: "kpi_v2_TRansaction"))
        
        Flagship.sharedInstance.sendHit(FSItem(transactionId: "idV2", name: "itemV2", code: "sku"))
        
        Flagship.sharedInstance.sendHit(FSPage("interfaceV2"))


    }
    
    
    
    /// Send Action
    
    @IBAction func onClikcButton(){
        
        let event = FSEvent(eventCategory: .User_Engagement, eventAction: "june_jeans_23")
        event.label = "mainProduct"
        event.eventValue = 1
        event.sessionNumber = 1
        event.userLanguage = "fr"
        event.screenResolution = "100*100"
        Flagship.sharedInstance.sendHit(event)
        
    }
    
    
    
       // Click Shoping
       @IBAction func onClikcThirdButton(){
          
           // Create event for CTA Action
           // The event action you give here is the name who should be displayed on the report
           let actionEvent:FSEvent = FSEvent(eventCategory: FSCategoryEvent.Action_Tracking, eventAction: "ctx_event1105")
           actionEvent.label = "ctx_event1105_label"
           actionEvent.eventValue = 1
           actionEvent.interfaceName = "HomeScreen"
           // Send Event Tracking
           Flagship.sharedInstance.sendHit(actionEvent)
           
       }

    
    
    
    @IBAction func onSwitch(){
        
        Flagship.sharedInstance.updateContext("isVip", vipSwitch.isOn)
        
        Flagship.sharedInstance.synchronizeModifications { (result) in
            
            DispatchQueue.main.async {
                
                /// Get Color for background defined in dashboard flagship
                let colorHexTitle =  Flagship.sharedInstance.getModification("backgroundColor", defaultString: "#b6fcd5", activate: false)
                
                /// Activate modification to tell Flagship that the user has seen this specific variation
                Flagship.sharedInstance.activateModification(key: "backgroundColor")
                self.view.backgroundColor = UIColor(hexString: colorHexTitle, alpha: 1.0)
                
                /// Get color for button
                self.firstButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)
                
                self.secondButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)
                
                self.thirdButton.backgroundColor = UIColor(hexString:Flagship.sharedInstance.getModification("btn-color", defaultString: "#ff7f50", activate: false), alpha: 1.0)

                
            }
        }
        
    }
    
    
    
}



 
