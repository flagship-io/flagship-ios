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
              var loadView:UIActivityIndicatorView!
    /// fb button
    @IBOutlet var faceBookBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        

        faceBookBtn.layer.cornerRadius = faceBookBtn.frame.height/2
        faceBookBtn.layer.masksToBounds = true
        
        
        
        loadView = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 100, height: 100))
        loadView.center = self.view.center
        loadView.color = .red
        loadView.startAnimating()
        self.view.addSubview(loadView)
        
        
        
        /// Loading view
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onFinish), userInfo: nil, repeats: false)
        
    }
    
 
    @objc func onFinish(){
        
        DispatchQueue.main.async {
            
            self.logInBtn.isHidden = false
            
            self.signInBtn.isHidden = false
            
            self.loadView.removeFromSuperview()
            
            self.faceBookBtn.isHidden = false

        }
    }
    
    
    
    
    
    
    @IBAction func onShowLoginScreen(){
        
        self.performSegue(withIdentifier: "showLoginScreen", sender:nil)
    }
    
}
