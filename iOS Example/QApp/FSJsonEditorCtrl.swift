//
//  FSJsonEditorCtrl.swift
//  FlagshipQA
//
//  Created by Adel on 23/02/2021.
//


import UIKit
import Flagship




class FSJsonEditorCtrl: UIViewController, UITextViewDelegate {

    
    
    
    @IBOutlet var jsonTextView:UITextView?
    
    @IBOutlet var validateJson:UIButton?
    
    var delegate:FSJsonEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Display welll printed json context
        displayWellprintedJsonContext()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard)))

    }
    
    
    @objc func hideKeyBoard(){
        
        self.jsonTextView?.endEditing(true)
    }
    
    
    
    private func displayWellprintedJsonContext(){
        
        if let jsonDico =  Flagship.sharedInstance.sharedVisitor?.getContext() {
            
            if jsonDico.count > 0 {
                
                let data = try! JSONSerialization.data(withJSONObject: jsonDico, options: .prettyPrinted)
                let prettyString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                jsonTextView?.text = prettyString as String?
            }
        }
        

    }
    
    
    @IBAction func onValidateJson(){
        /// get the string data from json view
        
        if let jsonText = jsonTextView?.text{
            
            let data = Data(jsonText.utf8)
            do {
                
                let dico =  try JSONSerialization.jsonObject(with: data, options:.fragmentsAllowed) as? [String:Any] ?? [:]
                
                Flagship.sharedInstance.sharedVisitor?.updateContext(dico)
                
                /// Tel delegate to do the update on config view
                delegate?.onUpdateContextFromEditor()
                
                
            }catch{
                
              //  jsonTextView?.text = "error - json not valide"
                
                 //return
            }
            
        }

        self.dismiss(animated: true, completion: nil)
    }
}


protocol FSJsonEditorDelegate {
    
    func onUpdateContextFromEditor()
}
