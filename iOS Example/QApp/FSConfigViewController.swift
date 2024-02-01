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
    @IBOutlet var createBtn: UIButton?
    @IBOutlet var fetchBtn: UIButton?

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
        FSCTools.roundButton(createBtn)
        createBtn?.isEnabled = false
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

            if newState == .READY || newState == .PANIC_ON || newState == .POLLING {
                DispatchQueue.main.async {
                    self.createBtn?.isEnabled = true
                }

                if mode == .BUCKETING {
                    Flagship.sharedInstance.sharedVisitor?.fetchFlags {
                        self.delegate?.onGetSdkReady()
                    }
                }
            }
        }.withTrackingManagerConfig(FSTrackingManagerConfig(poolMaxSize: 8, batchIntervalTimer: 10, strategy: .CONTINUOUS_CACHING)).withOnVisitorExposed { fromFlag, visitorExposed in

            print(fromFlag.toJson() ?? "")
            print(visitorExposed.toJson() ?? "")
        }.withCacheManager(FSCacheManager(CustomVisitorCache(), CustomHitCache())).withLogLevel(FSLevel.ERROR)

        if mode == .DECISION_API {
            fsConfig = fsConfigBuilder.DecisionApi().build()
        } else {
            fsConfig = fsConfigBuilder.Bucketing().build()
        }

        // Start the sdk
        Flagship.sharedInstance.start(envId: envIdTextField?.text ?? "", apiKey: apiKetTextField?.text ?? "", config: fsConfig)
    }

    @IBAction func onClickCreateVisitor() {
        fetchBtn?.isEnabled = true
        _ = createVisitor()
    }

    @IBAction func fetchFlags() {
        Flagship.sharedInstance.sharedVisitor?.fetchFlags(onFetchCompleted: {
            let st = Flagship.sharedInstance.getStatus()
            if st == .READY {
                self.delegate?.onGetSdkReady()
                DispatchQueue.main.async {
                    self.createBtn?.isEnabled = true
                }
            } else if st == .PANIC_ON {
                self.delegate?.onGetSdkReady()
                DispatchQueue.main.async {
                    self.createBtn?.isEnabled = true
                }
                self.showErrorMessage("Flagship, Panic Mode Activated")
            } else {
                self.showErrorMessage("Sorry, something went wrong, please check your envId and apiKey")
            }
        })
    }

    func createVisitor() -> FSVisitor {
        let userIdToSet: String = visitorIdTextField?.text ?? ""

        return Flagship.sharedInstance.newVisitor("p").hasConsented(hasConsented: allowTrackingSwitch?.isOn ?? true).withContext(context: ["segment": "coffee", "QA": "ios", "testing_tracking_manager": true, "isPreRelease": true, "test": 12]).isAuthenticated(authenticateSwitch?.isOn ?? false).build()
    }

    func showErrorMessage(_ msg: String) {
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

    func doc() {
        // Instanciate Custom cache manager
        let customCacheManager = FSCacheManager(CustomVisitorCache(), CustomHitCache())

        // Start the Flagship sdk
        Flagship.sharedInstance.start(envId: "_ENV_ID_", apiKey: "_API_KEY_", config: FSConfigBuilder()
            .DecisionApi()
            .withCacheManager(customCacheManager)
            .build())

        Flagship.sharedInstance.close()
    }
}

// Delegate
protocol FSConfigViewDelegate {
    func onGetSdkReady()
    func onResetSdk()
}

//
public class CustomVisitorCache: FSVisitorCacheDelegate {
    public func cacheVisitor(visitorId: String, _ visitorData: Data) {
        // Save the Data that represent the information for visitorId
    }

    public func lookupVisitor(visitorId: String) -> Data? {
        // Return the saved data of visitorId
        return Data()
    }

    public func flushVisitor(visitorId: String) {
        // Remove the data for visitorId
    }
}

public class CustomHitCache: FSHitCacheDelegate {
    // Save the dictionary that represent hits
    public func cacheHits(hits: [String: [String: Any]]) {}

    // Return the saved hit in your database
    public func lookupHits() -> [String: [String: Any]] {
        return [:]
    }

    // Remove the hit's id given with List
    public func flushHits(hitIds: [String]) {}

    // Remove all hits in database
    public func flushAllHits() {}
}

 
