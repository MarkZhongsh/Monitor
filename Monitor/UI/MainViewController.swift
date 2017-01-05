//
//  MainViewController.swift
//  Monitor
//
//  Created by suihong on 16/12/3.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation

class MainViewController : UINavigationController {
    
    var loginViewController:LoginViewController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loginViewController = LoginViewController()
//        self.setNavigationBarHidden(true, animated: false)
        
        pushViewController(loginViewController, animated: true)
        
    }
    
}
