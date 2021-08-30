//
//  FSConfigViewController.swift
//  QApp
//
//  Created by Adel on 23/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSConfigViewController: UIViewController, UITextFieldDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .lightContent
    }

    @IBOutlet var envIdTextField: UITextField?
    @IBOutlet var apiKetTextField: UITextField?
    @IBOutlet var visitorIdTextField: UITextField?
    @IBOutlet var authenticateSwitch: UISwitch?
    @IBOutlet var allowTrackingSwitch: UISwitch?


    @IBOutlet var visitorCtxLabel: UILabel?

    @IBOutlet var modeBtn: UIButton?

    @IBOutlet var resetBtn: UIButton?

    @IBOutlet var startBtn: UIButton?

    var delegate: FSConfigViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // set envid

        self.envIdTextField?.text = UserDefaults.standard.value(forKey: "idKey") as? String ?? ""
        self.apiKetTextField?.text = UserDefaults.standard.value(forKey: "idApiKey") as? String ?? ""
        self.visitorIdTextField?.text = nil
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
    @objc func hideKeyBoard() {

        self.view.endEditing(true)
    }

    // Hide KeyBoard
    @objc func showEditContext() {

        DispatchQueue.main.async {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let contextCtrl = storyboard.instantiateViewController(
                          withIdentifier: "contextPopUp")
            /// push view
            contextCtrl.modalPresentationStyle = .popover
            self.present(contextCtrl, animated: true) {

            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    @IBAction func onClikcStart() {

        let userIdToSet: String? = (visitorIdTextField?.text?.count == 0) ? nil : visitorIdTextField?.text

        /// Get the mode
        let mode: FlagshipMode =  modeBtn?.isSelected ?? false ? .BUCKETING : .DECISION_API

        let config  = FSConfig(mode, authenticated: self.authenticateSwitch?.isOn ?? false, isConsent: self.allowTrackingSwitch?.isOn ?? false)

        /// Start function
        Flagship.sharedInstance.start(envId: envIdTextField?.text ?? "", apiKey: apiKetTextField?.text ?? "", visitorId: userIdToSet, config: config) { (result) in

            DispatchQueue.main.async {

                /// Get the current context for you applicationflas
                self.visitorCtxLabel?.text = String(format: "%@", Flagship.sharedInstance.getVisitorContext())

            }

            if result == .Ready {

                self.delegate?.onGetSdkReady()
            } else {

                self.showErrorMessage()
            }
        }
    }

    internal func showErrorMessage() {

        DispatchQueue.main.async {

            let msg = "Sorry, something went wrong, please check your envId and apiKey"
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

    @IBAction func onClickModeBtn() {

        /// If sselected ====> Bucketing mode
        if let isSelectd = modeBtn?.isSelected {

            modeBtn?.isSelected = !isSelectd
        }
    }

    @IBAction func onClicResetBtn() {

        self.delegate?.onResetSdk()

        UserDefaults.standard.removeObject(forKey: "FlagShipIdKey")

        visitorIdTextField?.text = nil
        authenticateSwitch?.isOn = false
        visitorCtxLabel?.text = nil
        modeBtn?.isSelected = false

    }
    
    @IBAction func onSwitchTracking(){
        
        Flagship.sharedInstance.isConsent = self.allowTrackingSwitch?.isOn ?? false
        
        if self.allowTrackingSwitch?.isOn ?? false {
            
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ AllowTracking @@@@@@@@@@@@@@@@@@@@@@@@@")

        }else{
            
            print(" @@@@@@@@@@@@@@@@@@@@@@ No Tracking @@@@@@@@@@@@@@@@@@@@@@@@@")

        }
        
    }

    /// Delegate textfield

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        hideKeyBoard()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
}

///// Delegate

protocol FSConfigViewDelegate {

    func onGetSdkReady()

    func onResetSdk()

}
