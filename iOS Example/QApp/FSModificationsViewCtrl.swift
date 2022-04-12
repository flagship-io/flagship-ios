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
    @IBOutlet var isReferenceLabel:FSLabel?

    
    
    @IBOutlet var keyTextField:UITextField?
    
    @IBOutlet var defaultValueField:UITextField?
    
    @IBOutlet var defaultValueSwitch:UISwitch?
    
    @IBOutlet var typePicker:UIPickerView?
    
    @IBOutlet var activateBtn:UIButton?
    @IBOutlet var getBtn:UIButton?
    @IBOutlet var jsonViewBtn:UIButton?
    
    @IBOutlet var jsonView:UITextView?
    @IBOutlet var scrollView:UIScrollView?

    var flagObject:FSFlag?

    
    
    
    
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
        activateBtn?.isEnabled = false
        FSCTools.roundButton(getBtn)
        getBtn?.isEnabled = false
        FSCTools.roundButton(jsonViewBtn)


        
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
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput, defaultValue:defaultValueSwitch?.isOn ?? false)
                    
                    break
                case .StringType:
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput, defaultValue:defaultValueInput)
                    
                    break
                case .IntegerType:
                    
                    let inputInt = Int(String(format: "%@", defaultValueInput)) ?? 0
                    
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput, defaultValue:inputInt)
                    
                    break
                case .DoubleType:
                    
                    let inputDbl = Double(String(format: "%@", defaultValueInput)) ?? 0
                    flagObject = Flagship.sharedInstance.sharedVisitor?.getFlag(key: keyValueInput, defaultValue:inputDbl)
                    break
                }
                
                let dicoInfo = flagObject?.metadata().toJson()
                
                 /// check the existing key
                
                if let aFlagObject = flagObject{
                    
                    if aFlagObject.exists(){
                        
                        print("the key exist")
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.valueLabel?.text = "\(self.flagObject?.value() ?? "unknown")"
                    
                    self.variationIdLabel?.text = "\(dicoInfo?["variationId"] ?? "unknown")"
                    
                    self.variationGroupIdLabel?.text = "\(dicoInfo?["variationGroupId"] ?? "unknown")"
                    
                    self.campaigIdLabel?.text = "\(dicoInfo?["campaignId"] ?? "unknown")"
                    
                    self.isReferenceLabel?.text = (dicoInfo?["isReference"] as? Bool ?? false) ? "YES": "NO"
                }
        }
    }
    
}


@IBAction func onClickActivate(){
    
    if let keyToActivate = keyTextField?.text {
        
        if keyToActivate.count != 0{
            
            if let flag = flagObject {
                var msg:String = ""
                if flag.exists(){
                    
                    msg = "Activate \(keyToActivate)"
                    flag.userExposed()

                }else{
                    
                    msg = "\(keyToActivate) not found"
                }
                
                let alertCtrl = UIAlertController(title: "Flagship/Activate", message:msg, preferredStyle: .alert)
                alertCtrl.addAction(UIAlertAction(title: "OK", style: .cancel,handler: nil))
                self.present(alertCtrl, animated: true, completion: nil)
            
        }
        }
    }
}
    
    
    @IBAction func onClickJsonView(){
        
        /// If sselected ====> Bucketing mode
        if let isSelected = jsonViewBtn?.isSelected{
            
            jsonViewBtn?.isSelected = !isSelected
             
            if (!isSelected){
                 jsonView?.isHidden = false
                
                jsonView?.text = "All the modifictaions : \n"
                
     
                
                if let dataAPi = readCampaignFromCache(){

                    do {
                        let dico = try JSONSerialization.jsonObject(with: dataAPi, options: .fragmentsAllowed)
                        jsonView?.text.append("\n\n\n")
                        jsonView?.text.append("Api Response is : \n \(dico)")
                    } catch {


                    }



                }

                scrollView?.setContentOffset(.zero, animated: true)
                
             }else{
                 
                 jsonView?.isHidden = true
             }
        }
        
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
    
    if (textField.tag == 100){
        
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if (updatedText.count > 0){
            
            activateBtn?.isEnabled = true
            getBtn?.isEnabled = true

            
        }else{
            
            activateBtn?.isEnabled = false
            getBtn?.isEnabled = false

        }
        
    }
    else if(typePicker?.selectedRow(inComponent:0) == 2 || typePicker?.selectedRow(inComponent:0) == 1){
        
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        
        return (string.rangeOfCharacter(from: invalidCharacters) == nil)
        
    }
    return true
}




func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    self.view.endEditing(true)
    
}
    
    
    func readCampaignFromCache()->Data?{
        
        if var url:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Path
            url.appendPathComponent("FlagShipCampaign", isDirectory: true)
            // add file name
            url.appendPathComponent("campaigns.json")
            
            if (FileManager.default.fileExists(atPath: url.path) == true){
                
                do{
                  
                    
                    let data = try Data(contentsOf: url)
                    
                    return data
                }catch{
                    print("errror on read data")
                    return nil
                }
                
            }else{
                
                return nil
            }
        }
        return nil
    }
}


extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
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
