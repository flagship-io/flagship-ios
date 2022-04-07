//
//  FSLoggerCtrl.swift
//  FlagshipQA
//
//  Created by Adel on 24/02/2021.
//

import UIKit


 class FSLoggerCtrl: UIViewController {
    
    
    @IBOutlet var loggBtn:UIButton?
    
    
     override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        XNUIManager.shared.uiLogHandler.logFormatter.showCurlWithReqst = false
        XNUIManager.shared.uiLogHandler.logFormatter.showCurlWithResp = false
        XNUIManager.shared.presentUI()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    @IBAction func getLogHttp(){

    }

}
