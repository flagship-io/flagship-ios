//
//  FSConfigViewController.swift
//  QApp
//
//  Created by Adel on 23/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import Flagship
import UIKit

class FSConfigViewController: UIViewController, UITextFieldDelegate, FSJsonEditorDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet var allowTrackingSwitch: UISwitch?
    @IBOutlet var apiKetTextField: UITextField?
    @IBOutlet var authenticateSwitch: UISwitch?
    @IBOutlet var envIdTextField: UITextField?
    @IBOutlet var modeBtn: UIButton?
    @IBOutlet var resetBtn: UIButton?
    @IBOutlet var startBtn: UIButton?
    @IBOutlet var timeOutFiled: UITextField?
    @IBOutlet var visitorCtxLabel: UILabel?
    @IBOutlet var visitorIdTextField: UITextField?
    @IBOutlet var createAndFetchBtn: UIButton?

    var delegate: FSConfigViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set envid
        envIdTextField?.text = UserDefaults.standard.value(forKey: "idKey") as? String ?? ""
        apiKetTextField?.text = UserDefaults.standard.value(forKey: "idApiKey") as? String ?? ""

        // self.visitorIdTextField?.text = nil
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        visitorCtxLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showEditContext)))
        visitorCtxLabel?.isUserInteractionEnabled = true

        // Config mode button
        modeBtn?.setTitle("API", for: .normal)
        modeBtn?.setTitle(" BUCKETING ", for: .selected)

        FSCTools.roundButton(modeBtn)
        FSCTools.roundButton(startBtn)
        FSCTools.roundButton(resetBtn)
        FSCTools.roundButton(createAndFetchBtn)
        createAndFetchBtn?.isEnabled = false
    }

    // Hide KeyBoard
    @objc func hideKeyBoard() {
        view.endEditing(true)
    }

    // Hide KeyBoard
    @objc func showEditContext() {
        /// Display json textView
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let contextCtrl = storyboard.instantiateViewController(withIdentifier: "FSJsonEditorCtrl") as? FSJsonEditorCtrl {
                /// push view
                contextCtrl.modalPresentationStyle = .popover
                contextCtrl.delegate = self
                self.present(contextCtrl, animated: true) {}
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func onClikcStart() {
        // Get the mode
        let mode: FSMode = modeBtn?.isSelected ?? false ? .BUCKETING : .DECISION_API

        // Retreive the timeout value
        var timeOut = 2.0 /// Default value is 2 seconds

        if let timeOutInputValue = Double(timeOutFiled?.text ?? "2") {
            timeOut = timeOutInputValue
        }

        // Create config object
        let fsConfig: FlagshipConfig

        let fsConfigBuilder = FSConfigBuilder().DecisionApi().withTimeout(timeOut).withStatusListener { newState in

            if newState == .READY || newState == .PANIC_ON {
                
                DispatchQueue.main.async {
                    self.createAndFetchBtn?.isEnabled = true
                }
                
                if mode == .BUCKETING {
                    Flagship.sharedInstance.sharedVisitor?.fetchFlags {
                        self.delegate?.onGetSdkReady()
                      
                    }
                }
            }
        }.withTrackingConfig(FSTrackingConfig(poolMaxSize: 8, batchIntervalTimer: 10, strategy: .CONTINUOUS_CACHING))
        if mode == .DECISION_API {
            fsConfig = fsConfigBuilder.DecisionApi().build()
        } else {
            fsConfig = fsConfigBuilder.Bucketing().build()
        }

        // Start the sdk
        Flagship.sharedInstance.start(envId: envIdTextField?.text ?? "", apiKey: apiKetTextField?.text ?? "", config: fsConfig)

//        let currentVisitor = createVisitor()
//
//        currentVisitor.updateContext(.CARRIER_NAME, "SFR")
//
//        currentVisitor.synchronize { () in
//            let st = Flagship.sharedInstance.getStatus()
//            if st == .READY {
//                self.delegate?.onGetSdkReady()
//            } else if st == .PANIC_ON {
//                self.delegate?.onGetSdkReady()
//                self.showErrorMessage("Flagship, Panic Mode Activated")
//            } else {
//                self.showErrorMessage("Sorry, something went wrong, please check your envId and apiKey")
//            }
//        }
    }

    @IBAction func onClickCreateVisitor() {
        let currentVisitor = createVisitor()
        currentVisitor.synchronize { () in
            let st = Flagship.sharedInstance.getStatus()
            if st == .READY {
                self.delegate?.onGetSdkReady()
                DispatchQueue.main.async {
                    self.createAndFetchBtn?.isEnabled = true
                }
            } else if st == .PANIC_ON {
                self.delegate?.onGetSdkReady()
                DispatchQueue.main.async {
                    self.createAndFetchBtn?.isEnabled = true
                }
                self.showErrorMessage("Flagship, Panic Mode Activated")
            } else {
                self.showErrorMessage("Sorry, something went wrong, please check your envId and apiKey")
            }
        }
    }

    func createVisitor() -> FSVisitor {
        let userIdToSet: String = visitorIdTextField?.text ?? "UnknowVisitor"

        return Flagship.sharedInstance.newVisitor(userIdToSet).hasConsented(hasConsented: allowTrackingSwitch?.isOn ?? true).withContext(context: ["isPoc": true, "QA": "ios", "testing_tracking_manager": true]).isAuthenticated(authenticateSwitch?.isOn ?? false).build()
    }

    internal func showErrorMessage(_ msg: String) {
        DispatchQueue.main.async {
            let alertCtrl = UIAlertController(title: "Start", message: msg, preferredStyle: .alert)
            alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }

    @IBAction func onSwichAuthenticate() {
        if authenticateSwitch?.isOn ?? false {
            print(" @@@@@@@@@@@@@@@@@@@@@@ AUTHENTICATE IS TRUE @@@@@@@@@@@@@@@@@@@@@@@@@")
        } else {
            print(" @@@@@@@@@@@@@@@@@@@@@@ AUTHENTICATE IS FALSE @@@@@@@@@@@@@@@@@@@@@@@@@")
        }
    }

    @IBAction func onSwitchTracking() {
        Flagship.sharedInstance.sharedVisitor?.setConsent(hasConsented: allowTrackingSwitch?.isOn ?? false)

        if allowTrackingSwitch?.isOn ?? false {
            print(" @@@@@@@@@@@@@@@@@@@@@@ AllowTracking @@@@@@@@@@@@@@@@@@@@@@@@@")

        } else {
            print(" @@@@@@@@@@@@@@@@@@@@@@ No Tracking @@@@@@@@@@@@@@@@@@@@@@@@@")
        }
    }

    @IBAction func onClickModeBtn() {
        /// If sselected ====> Bucketing mode
        if let isSelectd = modeBtn?.isSelected {
            modeBtn?.isSelected = !isSelectd
        }
    }

    @IBAction func onClicResetBtn() {
        delegate?.onResetSdk()
        UserDefaults.standard.removeObject(forKey: "FlagShipIdKey")
        // set the api key and envid
        envIdTextField?.text = UserDefaults.standard.value(forKey: "idKey") as? String ?? ""
        apiKetTextField?.text = UserDefaults.standard.value(forKey: "idApiKey") as? String ?? ""
        visitorIdTextField?.text = nil
        authenticateSwitch?.isOn = false
        visitorCtxLabel?.text = nil
        modeBtn?.isSelected = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyBoard()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {}

    // Delegate JsonEditor
    func onUpdateContextFromEditor() {
        DispatchQueue.main.async {
            if let visitor = Flagship.sharedInstance.sharedVisitor {
                // Get the current context for you application
                self.visitorCtxLabel?.text = String(format: "%@", visitor.getContext())
            }
        }
    }
}

// Delegate
protocol FSConfigViewDelegate {
    func onGetSdkReady()
    func onResetSdk()
}

public class CustomClientVisitorCache: FSVisitorCacheDelegate {
    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        // Upsert in your database
    }

    public func lookupVisitor(visitorId: String) -> Data? {
        // Load & delete from your database
        return Data()
    }

    public func flushVisitor(visitorId: String) {
        // Clear from your database
    }
}

public class customClientHitCache: FSHitCacheDelegate {
    public func cacheHits(hits: [String: [String: Any]]) {}

    public func lookupHits() -> [String: [String: Any]] {
        return [:]
    }

    public func flushHits(hitIds: [String]) {}

    public func flushAllHits() {}

    public func cacheHit(visitorId: String, data: Data) {
        // Insert in your database
    }

    public func lookupHits(visitorId: String) -> [Data]? {
        // Delete and load from your database
        return []
    }

    public func flushHits(visitorId: String) {
        // Clear from your database
    }
}
