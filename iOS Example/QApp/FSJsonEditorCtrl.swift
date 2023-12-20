//
//  FSJsonEditorCtrl.swift
//  FlagshipQA
//
//  Created by Adel on 23/02/2021.
//

import Flagship
import UIKit

class FSJsonEditorCtrl: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var keysContext: [String] = []
    
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let editorView = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "ctxStoryId", creator: { coder -> FSContextCtrlViewEditor? in
                    
                    let key = self.keysContext[indexPath.row]
                    //FSContextCtrlViewEditor(coder: coder, dico: [key: jsonDico[key] ?? ""])
                })
                self.present(editorView, animated: true) {}
            }
        }
    }
    
    // @IBOutlet var jsonTextView:UITextView?
    
    @IBOutlet var validateJson: UIButton?
    
    var delegate: FSJsonEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let jsonDico = Flagship.sharedInstance.sharedVisitor?.getContext() { /// refractor later
            ///
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
    
    var dicoItem: [String: Any]?
    
    init?(coder: NSCoder, dico: [String: Any]) {
        self.dicoItem = dico
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(_ dicoItem: [String: Any]?) {
        self.dicoItem = dicoItem
        keyLabel?.text = dicoItem?.keys.first
        valueField?.text = "\(dicoItem?.values.first ?? "")"
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        keyLabel?.text = dicoItem?.keys.first
    }
    
    @IBAction func onValidate() {
        dismiss(animated: true)
    }
}

protocol FSContextViewEditorDelegate {
    func onEditContext()
}
