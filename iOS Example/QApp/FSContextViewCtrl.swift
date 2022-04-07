//
//  FSContextViewCtrl.swift
//  QApp
//
//  Created by Adel on 26/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship

class FSContextViewCtrl: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle {

        return .lightContent
    }

    let sourcePicker: [String] = ["String", "Integer", "Double", "Boolean"]

    @IBOutlet weak var keyField: UITextField!

    @IBOutlet weak var pickerView: UIPickerView!

    @IBOutlet weak var valueField: UITextField!

    @IBOutlet weak var valueSwitch: UISwitch!

    @IBOutlet weak var updateBtn: UIButton!

    @IBOutlet weak var currentCtx: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))

        self.currentCtx.text = String(format: "%@", Flagship.sharedInstance.getVisitorContext())

    }

    // Hide KeyBoard
    @objc func hideKeyBoard() {

        self.view.endEditing(true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {

        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourcePicker.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return sourcePicker[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        print(sourcePicker[row] as String)

        if sourcePicker[row] == "Boolean"{

            /// change textfiled to switch
            DispatchQueue.main.async {

                self.valueSwitch.isHidden = false
                self.valueField.isHidden = true

            }
        } else {

            DispatchQueue.main.async {

                self.valueSwitch.isHidden = true
                self.valueField.isHidden = false
            }

        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField.tag == 222 {

            if pickerView?.selectedRow(inComponent: 0) == 2 || pickerView?.selectedRow(inComponent: 0) == 1 {

                let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted

                return (string.rangeOfCharacter(from: invalidCharacters) == nil)

            }
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)

    }

    private func getTypeValue() -> FSValueType {

        switch pickerView?.selectedRow(inComponent: 0) {
        case 0:
            return .StringType
        case 1:
            return .IntegerType
        case 2:
            return .DoubleType
        case 3:
            return .BooleanType

        default:
            return .StringType
        }
    }

    @IBAction func onClikcUpdateCtx() {

        let keyInput = keyField?.text ?? ""

        // get default value
        if keyInput.count != 0 {

            if let valueInput = valueField?.text {

                /// Get the current selected
                let typeValue = getTypeValue()

                switch typeValue {
                case .BooleanType:
                    Flagship.sharedInstance.updateContext(keyInput, valueSwitch?.isOn ?? false)
                    break
                case .StringType:
                    Flagship.sharedInstance.updateContext(keyInput, valueInput)
                    break
                case .IntegerType:

                    let inputInt = Int(String(format: "%@", valueInput)) ?? 0
                    Flagship.sharedInstance.updateContext(keyInput, inputInt)

                    break
                case .DoubleType:

                    let inputDbl = Double(String(format: "%@", valueInput)) ?? 0
                    Flagship.sharedInstance.updateContext(keyInput, inputDbl)

                    break
                }

                DispatchQueue.main.async {

                    self.currentCtx.text = String(format: "%@", Flagship.sharedInstance.getVisitorContext())

                    self.valueField.text = nil
                    self.keyField.text = nil
                }

        }
    }
}

}
