//
//  FSUserViewCtrl.swift
//  QApp
//
//  Created by Adel on 23/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship
class FSUserViewCtrl: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
    
    
    @IBOutlet var visitorTextField:UITextField?
    @IBOutlet var anonymousIdField:UITextField?
    @IBOutlet var newVisitorField:UITextField?
    
    
    @IBOutlet var authBtn:UIButton?
    @IBOutlet var unAuthBtn:UIButton?
    @IBOutlet var syncBtn:UIButton?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redPlaceholderText = NSAttributedString(string: "New authenticated id",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                
        newVisitorField?.attributedPlaceholder = redPlaceholderText
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        
        FSCTools.roundButton(authBtn)
        FSCTools.roundButton(unAuthBtn)
        FSCTools.roundButton(syncBtn)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
       self.visitorTextField?.text =  Flagship.sharedInstance.sharedVisitor?.visitorId
        
        self.anonymousIdField?.text = Flagship.sharedInstance.sharedVisitor?.anonymousId

        
    }
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
    }
    
    internal func updateIds(){
        
        DispatchQueue.main.async {
            
            self.visitorTextField?.text =  Flagship.sharedInstance.sharedVisitor?.visitorId
            
            self.anonymousIdField?.text = Flagship.sharedInstance.sharedVisitor?.anonymousId
        }
    }
    
    
    internal func cleanViewField(){
        
        DispatchQueue.main.async {
            
            self.visitorTextField?.text =  nil
            
            self.anonymousIdField?.text = nil
            
            self.newVisitorField?.text = nil
        }
    }
    
    
    /// authenticate
    @IBAction func authenticate(){
        
        if let userId = newVisitorField?.text{
            
            Flagship.sharedInstance.sharedVisitor?.authenticate(visitorId: userId)
            
            self.updateIds()
        }

    }
    
    
    /// unAuthenticate
    @IBAction func unAuthenticate(){
        
        Flagship.sharedInstance.sharedVisitor?.unauthenticate()
        self.updateIds()
    }
    
    
    /// Synchronize
    @IBAction func synchronize(){
        
        Flagship.sharedInstance.sharedVisitor?.synchronize(onSyncCompleted: {()  in
            
            
        })
    }
    
    
 
    
    
    
    
}
