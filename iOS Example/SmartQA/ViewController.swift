//
//  ViewController.swift
//  SmartQA
//
//  Created by Adel Ferguen on 19/05/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit
import WebKit
class ViewController: UIViewController {
    @IBOutlet var startQABtn: UIButton?
    @IBOutlet var activateQABtn: UIButton?
    var tapGesture: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startQA() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            print("Start collecting emotion AI")
            Flagship.sharedInstance.sharedVisitor?.startCollectingEmotionAI(window: window, usingSwizzling: true)
        }
        
        // Do any additional setup after loading the view.
    }
 
    /// Add one more activate
    @IBAction func activate() {
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            print("Fetch flags done successfully")
            
            self.performSegue(withIdentifier: "onActivate", sender: self)
        }
    }

    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.getFlag(key: "eai-var").visitorExposed()
        Flagship.sharedInstance.sharedVisitor?.sendHit(FSEvent(eventCategory: FSCategoryEvent.User_Engagement, eventAction: "eai-segment"))
    }
}
