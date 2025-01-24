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

    @IBOutlet var flagButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startQA() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            print("Start collecting emotion AI")
            Flagship.sharedInstance.sharedVisitor?.collectEmotionsAIEvents(window: window, screenName: "LoginScreen")
        }
    }

    /// Add one more activate
    @IBAction func activate() {
        performSegue(withIdentifier: "onActivate", sender: self)
    }

    @IBAction func sendHits() {
        Flagship.sharedInstance.sharedVisitor?.fetchFlags {
            print("Fetch flags done successfully")
            let value = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btn-title").value(defaultValue: "Buy")

            let btnColor = Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btnColor").value(defaultValue: "none")

            Flagship.sharedInstance.sharedVisitor?.getFlag(key: "btn-title").visitorExposed()

            DispatchQueue.main.async {
                switch btnColor {
                    case "red":
                        self.flagButton?.backgroundColor = .red
                        self.flagButton?.titleLabel?.textColor = .blue

                    case "blue":
                        self.flagButton?.backgroundColor = .blue
                        self.flagButton?.titleLabel?.textColor = .red

                    case "green":
                        self.flagButton?.backgroundColor = .green
                        self.flagButton?.titleLabel?.textColor = .blue
                    default:
                        self.flagButton?.backgroundColor = .orange
                        self.flagButton?.titleLabel?.textColor = .red
                }
                self.flagButton?.setTitle(value, for: .normal)
            }
        }
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        print("handle pan gesture from app level view controller")
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("handle long press gesture from app level view controller")
    }
}
