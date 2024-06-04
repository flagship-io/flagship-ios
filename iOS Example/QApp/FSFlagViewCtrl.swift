//
//  FSFlagViewCtrl.swift
//  QApp
//
//  Created by Adel Ferguen on 19/09/2023.
//  Copyright © 2023 FlagShip. All rights reserved.
//

import Flagship
import UIKit

enum FSValueType {
    case DoubleType
    case IntegerType
    case StringType
    case BooleanType
}

class FSFlagViewCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var currentFlag: FSFlag?
    @IBOutlet var flagView: FlagView?
    @IBOutlet var tableViewFlag: UITableView?
    @IBOutlet var activateBtn: UIButton?
    @IBOutlet var getValueFlagBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flagView?.layer.cornerRadius = 5
        flagView?.layer.masksToBounds = true
        
        tableViewFlag?.layer.cornerRadius = 5
        tableViewFlag?.layer.masksToBounds = true
        
        FSCTools.roundButton(activateBtn)
        FSCTools.roundButton(getValueFlagBtn)
        
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
    }
    
    // Hide KeyBoard
    @objc func hideKeyBoard() {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "flagCell") as? FlagViewCell
        
        cell?.configCell(currentFlag)
        
        return cell ?? UITableViewCell()
    }
    
    @IBAction func getFlag() {
        currentFlag = flagView?.prepareAndGetGetFlag()
        currentFlag
        tableViewFlag?.reloadData()
    }
    
    @IBAction func exposeFlag() {
        if let aCurrentFlag = currentFlag {
            aCurrentFlag.visitorExposed()
        }
    }
}

class FlagView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    let sourcePicker: [String] = ["String", "Integer", "Double", "Boolean"]
    
    // Picker view
    @IBOutlet var pickerView: UIPickerView?
    // Key for flag
    @IBOutlet var keyForFlagField: UITextField?
    // default value
    @IBOutlet var defaultValueField: UITextField?
    
    @IBOutlet var defaultValueSwitch: UISwitch?
    
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
    
        if sourcePicker[row] == "Boolean" {
            /// change textfiled to switch
            DispatchQueue.main.async {
                self.defaultValueSwitch?.isHidden = false
                self.defaultValueField?.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.defaultValueSwitch?.isHidden = true
                self.defaultValueField?.isHidden = false
            }
        }
    }
    
    func prepareAndGetGetFlag() -> FSFlag? {
        var flagObject: FSFlag?
        
        if let defaultValueInput = defaultValueField?.text {
            if let keyValueInput = keyForFlagField?.text {
                /// Get the current selected
                let typeValue = getTypeValue()
                
                switch typeValue {
                case .BooleanType:
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput /* , defaultValue: defaultValueSwitch?.isOn ?? false */ )

                    flagObject?.value(defaultValue: defaultValueSwitch?.isOn ?? false, visitorExposed: false)
                    
                case .StringType:
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput /* , defaultValue: defaultValueInput */ )
                    
                    flagObject?.value(defaultValue: defaultValueInput, visitorExposed: false)
                    
                case .IntegerType:
                    
                    let inputInt = Int(String(format: "%@" /* , defaultValueInput */ )) ?? 0
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput /* , defaultValue: inputInt */ )
                    flagObject?.value(defaultValue: inputInt, visitorExposed: false)
                    
                case .DoubleType:
                    
                    let inputDbl = Double(String(format: "%@", defaultValueInput)) ?? 0
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput /* , defaultValue: inputDbl */ )
                    flagObject?.value(defaultValue: inputDbl)
                }
                
                let dicoInfo = flagObject?.metadata().toJson()
                
                print(" ----------- Status fo visitor is \(Flagship.sharedInstance.sharedVisitor?.fetchStatus.rawValue ?? "") --------------")
 
                print(" ----------- Status for flag : \(keyValueInput) is \(flagObject?.status.rawValue ?? "") --------------")
            }
        }
        
        return flagObject
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100 {
            let currentText = textField.text ?? ""

            // attempt to read the range they are trying to change, or exit if we can't
            guard let stringRange = Range(range, in: currentText) else { return false }

            // add their new text to the existing text
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        } else if pickerView?.selectedRow(inComponent: 0) == 2 || pickerView?.selectedRow(inComponent: 0) == 1 {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
        return true
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { // NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

class FSLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 223/250, green: 68/250, blue: 110/250, alpha: 1).cgColor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
