//
//  FSConfigViewController.swift
//  QApp
//
//  Created by Adel on 23/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSConfigViewController: UIViewController, UITextFieldDelegate, FSJsonEditorDelegate {
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
    
    @IBOutlet var envIdTextField:UITextField?
    @IBOutlet var apiKetTextField:UITextField?
    @IBOutlet var visitorIdTextField:UITextField?
    @IBOutlet var authenticateSwitch:UISwitch?
    @IBOutlet var allowTrackingSwitch: UISwitch?
    
    @IBOutlet var timeOutFiled:UITextField?
    
    
    
    @IBOutlet var visitorCtxLabel:UILabel?
    
    @IBOutlet var modeBtn:UIButton?
    
    @IBOutlet var resetBtn:UIButton?
    
    @IBOutlet var startBtn:UIButton?
    
    
    
    
    
    
    var delegate:FSConfigViewDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set envid
        self.envIdTextField?.text = UserDefaults.standard.value(forKey: "idKey") as? String ?? ""
        self.apiKetTextField?.text = UserDefaults.standard.value(forKey: "idApiKey") as? String ?? ""
        //self.visitorIdTextField?.text = nil
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        self.visitorCtxLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showEditContext)))
        self.visitorCtxLabel?.isUserInteractionEnabled = true
        
        /// Config mode button
        modeBtn?.setTitle("API", for: .normal)
        modeBtn?.setTitle(" BUCKETING ", for: .selected)
        
        FSCTools.roundButton(modeBtn)
        FSCTools.roundButton(startBtn)
        FSCTools.roundButton(resetBtn)
        
        
        
    }
    
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
    }
    
    // Hide KeyBoard
    @objc func showEditContext(){
        
        /// Display json textView
        DispatchQueue.main.async {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let contextCtrl = storyboard.instantiateViewController( withIdentifier: "FSJsonEditorCtrl") as? FSJsonEditorCtrl{
                
                ///push view
                contextCtrl.modalPresentationStyle = .popover
                contextCtrl.delegate = self
                self.present(contextCtrl, animated: true) {
                    
                }
                
            }
            
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func createVisitor()->FSVisitor{
        
        let userIdToSet:String = visitorIdTextField?.text ?? "UnknowVisitor"
        
        return  Flagship.sharedInstance.newVisitor(userIdToSet).hasConsented(hasConsented: self.allowTrackingSwitch?.isOn ?? true).withContext(context: ["isPoc":true, "plan":"enterprise" ,"qa_report_xpc2":true, "cacheEnabled":true]).isAuthenticated(self.authenticateSwitch?.isOn ?? false).build()
        
    }
    
    
    @IBAction func onClikcStart(){
        
        /// Get the mode
        ///         let mode:FSMode =   modeBtn?.isSelected ?? false ? .BUCKETING : .DECISION_API
        
        let mode:FSMode =   modeBtn?.isSelected ?? false ? .BUCKETING : .DECISION_API
      /// Create configuaration
         //   let fsConfig = FSConfigBuilder().withMode(mode).withisAuthenticate(self.authenticateSwitch?.isOn ?? false).withCacheManager(FSCacheManager(CustomClientVisitorCache(), customClientHitCache())).build()
        
        
        /// Retreive the timeout value
        
        var timeOut:Double = 2.0 /// Default value is 2 seconds
        
        if let timeOutInputValue = Double(self.timeOutFiled?.text ?? "2"){
            
            timeOut = timeOutInputValue
        }
        
        /// Create config object
        let fsConfig = FSConfigBuilder().DecisionApi().withTimeout(timeOut).withStatusListener { newState in
            
            if newState == .READY || newState == .PANIC_ON {
                
                if mode == .BUCKETING {
                    
                    Flagship.sharedInstance.sharedVisitor?.fetchFlags {
                        
                        self.delegate?.onGetSdkReady()
                    }
                }
            }
            
        }.build()
        
        /// Start the sdk
        Flagship.sharedInstance.start(envId: envIdTextField?.text ?? "", apiKey: apiKetTextField?.text ?? "", config: fsConfig)
        
        let currentVisitor = createVisitor()
        
        currentVisitor.updateContext(.CARRIER_NAME, "SFR")
        
        currentVisitor.synchronize { () in
            let st = Flagship.sharedInstance.getStatus()
            if st == .READY{
                self.delegate?.onGetSdkReady()
            }else if st == .PANIC_ON{
                self.delegate?.onGetSdkReady()
                self.showErrorMessage("Flagship, Panic Mode Activated")
            }else{
                self.showErrorMessage("Sorry, something went wrong, please check your envId and apiKey")
            }
        }
    }
    
    
    internal func showErrorMessage(_ msg:String) {
        
        DispatchQueue.main.async {
            let alertCtrl = UIAlertController(title: "Start", message: msg, preferredStyle: .alert)
            alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    
    
    
    @IBAction func onSwichAuthenticate(){
        
        if (authenticateSwitch?.isOn ?? false) {
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ AUTHENTICATE IS TRUE @@@@@@@@@@@@@@@@@@@@@@@@@")
        }else{
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ AUTHENTICATE IS FALSE @@@@@@@@@@@@@@@@@@@@@@@@@")
        }
    }
    
    @IBAction func onSwitchTracking(){
        
        Flagship.sharedInstance.sharedVisitor?.setConsent(hasConsented:self.allowTrackingSwitch?.isOn ?? false)
        
        if self.allowTrackingSwitch?.isOn ?? false {
            
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ AllowTracking @@@@@@@@@@@@@@@@@@@@@@@@@")
            
        }else{
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ No Tracking @@@@@@@@@@@@@@@@@@@@@@@@@")
            
        }
        
    }
    
    
    
    @IBAction func onClickModeBtn(){
        
        /// If sselected ====> Bucketing mode
        if let isSelectd = modeBtn?.isSelected{
            
            modeBtn?.isSelected = !isSelectd
        }
    }
    
    
    
    @IBAction func onClicResetBtn(){
        self.delegate?.onResetSdk()
        UserDefaults.standard.removeObject(forKey: "FlagShipIdKey")
        /// set the api key and envid
        self.envIdTextField?.text = UserDefaults.standard.value(forKey: "idKey") as? String ?? ""
        self.apiKetTextField?.text = UserDefaults.standard.value(forKey: "idApiKey") as? String ?? ""
        visitorIdTextField?.text = nil
        authenticateSwitch?.isOn = false
        visitorCtxLabel?.text = nil
        modeBtn?.isSelected = false
    }
    
    
    
    /// Delegate textfield
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        hideKeyBoard()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        
    }
    
    /// Delegate JsonEditor
    
    func onUpdateContextFromEditor() {
        
        DispatchQueue.main.async {
            if let visitor = Flagship.sharedInstance.sharedVisitor {
                
                /// Get the current context for you application
                self.visitorCtxLabel?.text = String(format: "%@",visitor.getContext())
            }
        }
    }
    
    //// Tempo for demo
    
    func demoMe(){
        
       
        
        Flagship.sharedInstance.start(envId:"_ENV_ID_", apiKey: "_API_KEY_",
                                      config: FSConfigBuilder().DecisionApi()
                                        .withTimeout(500)
                                        .withLogLevel(.ALL).build())
        
        
/// Instanciate Custom cache manager
let customCacheManager = FSCacheManager(CustomClientVisitorCache(),customClientHitCache())

Flagship.sharedInstance.start(envId: "_ENV_ID_", apiKey: "_API_KEY_",config:FSConfigBuilder()
                  .DecisionApi()
                  .withCacheManager(customCacheManager)
                  .build())

        
    }
    
    
    


}


///// Delegate
///
protocol FSConfigViewDelegate {
    
    func onGetSdkReady()
    
    func onResetSdk()
    
    
    
    
}

public class CustomClientVisitorCache:FSVisitorCacheDelegate {
    
    
    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        /// Upsert in your database
    }
    
    
 
    public func lookupVisitor(visitorId: String)->Data?{
        // Load & delete from your database
        return Data()
    }
    
    
    
    public func flushVisitor(visitorId: String) {
        // Clear from your database
    }
}



public class customClientHitCache:FSHitCacheDelegate{
    
    public func cacheHit(visitorId: String, data: Data) {
       
        // Insert in your database
    }
    
    public func lookupHits(visitorId: String) ->[Data]? {
        
        // Delete and load from your database
        return []
    }
    
    public func flushHits(visitorId: String) {
        
        // Clear from your database
    }
}

