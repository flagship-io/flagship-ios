//
//  FSModificationsViewCtrl.swift
//  QApp
//
//  Created by Adel on 24/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit
import Flagship



internal enum FSValueType {
    
    case DoubleType
    case IntegerType
    case StringType
    case BooleanType
}



class FSModificationsViewCtrl: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
 
    
    
    
    let sourcePicker:[String] = ["String","Integer","Double","Boolean"]
    
    
    
    
    @IBOutlet var valueLabel:FSLabel?
    @IBOutlet var variationIdLabel:FSLabel?
    @IBOutlet var variationGroupIdLabel:FSLabel?
    @IBOutlet var campaigIdLabel:FSLabel?
    
    
    @IBOutlet var keyTextField:UITextField?
    
    @IBOutlet var defaultValueField:UITextField?
    
    @IBOutlet var defaultValueSwitch:UISwitch?
    
    @IBOutlet var typePicker:UIPickerView?
    
    @IBOutlet var activateBtn:UIButton?
    @IBOutlet var getBtn:UIButton?

    
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let redPlaceholderText = NSAttributedString(string: "Default value",
                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        defaultValueField?.attributedPlaceholder = redPlaceholderText
        
        // Set the default value for picker
        typePicker?.selectRow(0, inComponent:0, animated:true)
        defaultValueSwitch?.isHidden = true
        
        
        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
        
        FSCTools.roundButton(activateBtn)
        FSCTools.roundButton(getBtn)

        
    }
    
    // Hide KeyBoard
    @objc func hideKeyBoard(){
        
        self.view.endEditing(true)
    }
    
    
    
    
    
    /// Actions
    
    @IBAction func onClikcGetValue(){
        
        let result:Any?
        
        // get default value
        if let defaultValueInput = defaultValueField?.text {
            
            if let keyValueInput = keyTextField?.text {
                
                /// Get the current selected
                let typeValue = getTypeValue()
                
                switch typeValue {
                case .BooleanType:
                    
                    result = Flagship.sharedInstance.getModification(keyValueInput, defaultBool:defaultValueSwitch?.isOn ?? false )
                    break
                case .StringType:
                    result = Flagship.sharedInstance.getModification(keyValueInput, defaultString: defaultValueInput)
                    break
                case .IntegerType:
                    
                    let inputInt = Int(String(format: "%@", defaultValueInput)) ?? 0
                    result = Flagship.sharedInstance.getModification(keyValueInput, defaultInt:inputInt)
                    break
                case .DoubleType:
                    
                    let inputDbl = Double(String(format: "%@", defaultValueInput)) ?? 0
                    result = Flagship.sharedInstance.getModification(keyValueInput, defaultDouble:inputDbl)
                    break
                }
                
                
                let dicoInfo = Flagship.sharedInstance.getModificationInfo(keyValueInput)
                
                //      @return { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”} or nil
                
                DispatchQueue.main.async {
                    
                    self.valueLabel?.text = "\(result ?? "unknown")"
                    
                    self.variationIdLabel?.text = "\(dicoInfo?["variationId"] ?? "unknown")"
                    
                    self.variationGroupIdLabel?.text = "\(dicoInfo?["variationGroupId"] ?? "unknown")"
                    
                    self.campaigIdLabel?.text = "\(dicoInfo?["campaignId"] ?? "unknown")"
                    
                    
                }
            
        }
    }
    
    //        if let keyValue = keyTextField?.text {
    //
    //            let resultValue = Flagship.sharedInstance.getModification(keyValue, defaultString:"valll")
    //
    //            /// Display value
    //
    //            let dicoInfo = Flagship.sharedInstance.getModificationInfo(keyValue)
    //
    //            //      @return { “campaignId”: “xxxx”, “variationGroupId”: “xxxx“, “variationId”: “xxxx”} or nil
    //
    //            DispatchQueue.main.async {
    //
    //                self.valueLabel?.text = "\(resultValue)"
    //
    //                self.variationIdLabel?.text = "\(dicoInfo?["variationId"] ?? "unknown")"
    //
    //                self.variationGroupIdLabel?.text = "\(dicoInfo?["variationGroupId"] ?? "unknown")"
    //
    //                self.campaigIdLabel?.text = "\(dicoInfo?["campaignId"] ?? "unknown")"
    //
    //
    //            }
    //        }
    
}


@IBAction func onClickActivate(){
    
    Flagship.sharedInstance.getModification("btnTitle", defaultString: "toto", activate: true)
}



//// delegate picker

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
            
            self.defaultValueSwitch?.isHidden = false
            self.defaultValueField?.isHidden = true
            
        }
    }else{
        
        DispatchQueue.main.async {
            
            self.defaultValueSwitch?.isHidden = true
            self.defaultValueField?.isHidden = false
        }
        
    }
}


// ["String","Integer","Double","Boolean"]

private func getTypeValue()->FSValueType{
    
    switch typePicker?.selectedRow(inComponent: 0) {
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



//// delegate text field
/// Review this part
func textFieldDidEndEditing(_ textField: UITextField) {
    //
    //        var inputDouble:Double
    //        var inputInt:Int
    //
    //        if (textField.tag == 2020){
    //
    //            if (textField.text?.contains(",") ?? false){
    //
    //                inputDouble = textField.text?.doubleValue ?? 0
    //                   Flagship.sharedInstance.updateContext(NumberKey, inputDouble)
    //
    //            }else if (textField.text?.contains(".") ?? false){
    //
    //                inputDouble = textField.text?.doubleValue ?? 0
    //                   Flagship.sharedInstance.updateContext(NumberKey, inputDouble)
    //            }else{
    //
    //                inputInt = Int(String(format: "%@", textField.text ?? "0")) ?? 0
    //                   Flagship.sharedInstance.updateContext(NumberKey, inputInt)
    //            }
    //        }
    
}



func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    if (typePicker?.selectedRow(inComponent:0) == 2 || typePicker?.selectedRow(inComponent:0) == 1){
        
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
        return (string.rangeOfCharacter(from: invalidCharacters) == nil)
        
    }
    return true
}




func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    self.view.endEditing(true)
    
}

}



















class FSLabel:UILabel{
    
    
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
