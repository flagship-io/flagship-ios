//
//  FSJsonEditorCtrl.swift
//  FlagshipQA
//
//  Created by Adel on 23/02/2021.
//

import Flagship
import UIKit

class FSJsonEditorCtrl: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, FSContextViewEditorDelegate {
    @IBOutlet var tableView: UITableView!
    var keysContext: [String] = []
    var editorView: FSContextCtrlViewEditor?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() {
            return jsonDico.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FSContextUserCell = tableView.dequeueReusableCell(withIdentifier: "ctxCell")! as! FSContextUserCell
        
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() { /// refractor later
            ///
            let itemKey = keysContext[indexPath.row]
            
            let itemValue = jsonDico[itemKey]
            
            cell.conficCell(itemKey, itemValue)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() {
            DispatchQueue.main.async {
                self.editorView = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "ctxStoryId", creator: { coder -> FSContextCtrlViewEditor? in
                    
                    let key = self.keysContext[indexPath.row]
                    return FSContextCtrlViewEditor(coder: coder, key, jsonDico[key] ?? "")
                })
                
                if let aEditorView = self.editorView {
                    aEditorView.delegate = self
                    // center the view relative to it's superview coordinates
                    aEditorView.view.center = self.view.center
                    self.view.addSubview(aEditorView.view)
                    // UIView.transition(from: self.view, to: aEditorView.view, duration: 0.2)
                }
            }
        }
    }
    
    // @IBOutlet var jsonTextView:UITextView?
    
    @IBOutlet var validateJson: UIButton?
    
    var delegate: FSJsonEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() { /// refractor later
            keysContext.append(contentsOf: jsonDico.keys)
        }
        
        /// Display welll printed json context
        displayWellprintedJsonContext()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))
    }
    
    @objc func hideKeyBoard() {
        //  self.jsonTextView?.endEditing(true)
    }
    
    private func displayWellprintedJsonContext() {
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() {
            if jsonDico.count > 0 {
                let data = try! JSONSerialization.data(withJSONObject: jsonDico, options: .prettyPrinted)
                let prettyString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                //  jsonTextView?.text = prettyString as String?
            }
        }
    }
    
    @IBAction func onValidateJson() {
        dismiss(animated: true, completion: nil)
    }
    
    func onEditContext(_ key: String, _ newVal: Any) {
        Flagship.sharedInstance.sharedVisitor?.updateContext(key, newVal)
        tableView.reloadData()
    }
}

protocol FSJsonEditorDelegate {
    func onUpdateContextFromEditor()
}

class FSContextUserCell: UITableViewCell {
    @IBOutlet var keyLabel: UILabel?
    @IBOutlet var valueLabel: UILabel?

    func conficCell(_ key: String, _ value: Any?) {
        keyLabel?.text = key
        valueLabel?.text = "\(value ?? "")"
    }
}

class FSContextCtrlViewEditor: UIViewController, UITextFieldDelegate {
    var delegate: FSContextViewEditorDelegate?
    @IBOutlet var keyLabel: UILabel?
    @IBOutlet var valueField: UITextField?
    @IBOutlet var switchValue: UISwitch?
    
    var key: String
    var value: Any
    
    init?(coder: NSCoder, _ key: String, _ value: Any) {
        self.key = key
        self.value = value
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        keyLabel?.text = key
        if value is Bool {
            switchValue?.isHidden = false
            valueField?.isHidden = true
            switchValue?.isOn = value as? Bool ?? false
        } else if value is String {
            switchValue?.isHidden = true
            valueField?.isHidden = false
            valueField?.text = value as? String ?? ""
            valueField?.keyboardType = .default
        } else if value is Int || value is Double {
            switchValue?.isHidden = true
            valueField?.isHidden = false
            valueField?.text = "\(value)"
            valueField?.keyboardType = .decimalPad
        }
    }
    
    @IBAction func onValidate() {
        if let currentText = valueField?.text {
            let newVal: Any
            if value is Int {
                newVal = Int(currentText) ?? 0
            } else if value is Double {
                newVal = Double(currentText) ?? 0.0
            } else if value is Bool {
                newVal = switchValue?.isOn ?? false
            } else {
                newVal = currentText
            }
            delegate?.onEditContext(key, newVal)
        }
        view.removeFromSuperview()
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        // get the current text, or use an empty string if that failed
//        let currentText = textField.text ?? ""
//
//        // attempt to read the range they are trying to change, or exit if we can't
//        guard let stringRange = Range(range, in: currentText) else { return false }
//
//        // add their new text to the existing text
//        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//
//        // make sure the result is under 16 characters
//        return true
//    }
}

protocol FSContextViewEditorDelegate {
    func onEditContext(_ key: String, _ newVal: Any)
}
