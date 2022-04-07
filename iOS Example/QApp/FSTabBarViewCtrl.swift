//
//  FSTabBarViewCtrl.swift
//  QApp
//
//  Created by Adel on 23/11/2020.
//  Copyright © 2020 FlagShip. All rights reserved.
//

import UIKit


class FSTabBarViewCtrl: UITabBarController, FSConfigViewDelegate, UITabBarControllerDelegate {
    
    
    static let tabBarVc  = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: "xnlMainTabBarController") as? UITabBarController
    
    
   
    override var preferredStatusBarStyle: UIStatusBarStyle{
        
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = FSTabBarViewCtrl.tabBarVc?.viewControllers?.first as? UINavigationController{
            
            if let logViewCtrl = nav.topViewController {
                
                logViewCtrl.tabBarItem  = UITabBarItem(title: "Logs", image: UIImage(named: "logs"), selectedImage: nil)

                self.viewControllers?.append(nav.topViewController ?? UIViewController())

            }
            
        }
        
        
       

        // Do any additional setup after loading the view.
        
        if let configCtrl = self.viewControllers?.first as? FSConfigViewController{
            
            configCtrl.delegate = self
        }
    }
    
    
    
    
    
    /// Delegate
    
    /// Delegate FSConfig
    
    func onGetSdkReady() {
        
        let indexForUserCtrl = 1
        DispatchQueue.main.async {
            
            let isValidIndex = indexForUserCtrl >= 0 && indexForUserCtrl <  self.viewControllers?.count ?? 0
            
            if (isValidIndex){
                
                if let userController = self.viewControllers?[indexForUserCtrl] as? FSUserViewCtrl{
                    
                    userController.updateIds()
                   
                }
            }
            
            if let arrayItem = self.tabBar.items {
                
                for item:UITabBarItem in arrayItem {
                    
                //    if (item.title != "User"){  ///let xpc feature running 
                        
                        item.isEnabled = true
               //     }
                    
                    
                }
            }
        }
    }
    
    
    func onResetSdk(){
        
        let indexForUserCtrl = 1
        
        let isValidIndex = indexForUserCtrl >= 0 && indexForUserCtrl <  self.viewControllers?.count ?? 0
        
        if (isValidIndex){
            
            if let userController = self.viewControllers?[indexForUserCtrl] as? FSUserViewCtrl{
                
                    userController.cleanViewField()
               
            }
        }
        DispatchQueue.main.async {
                
                if let arrayItem = self.tabBar.items {
                    
                    for item:UITabBarItem in arrayItem {
                        
                        item.isEnabled = false
                       
                    }
                }
            }
        
    }
}


