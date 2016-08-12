//
//  LoginViewController.swift
//  Monitor
//
//  Created by suihong on 16/7/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

import SnapKit
import Foundation
import UIKit

protocol LoginDelegate {
    func login(account: String, password: String)
}

class LoginViewController : UIViewController {
    
    var pwdField: UITextField!
    var accountFiled: UITextField!
    
    var delegate: LoginDelegate?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let mainView = UIView()
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        mainView.addGestureRecognizer(tapGes)
        self.view.addSubview(mainView)
        
        mainView.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(50)
            make.bottom.equalTo(-50)
            make.trailing.leading.equalTo(0)
        })
        
        let titleView = self.topTitle()
        mainView.addSubview(titleView)
        titleView.snp_makeConstraints(closure: { (make) -> Void in
            let topOffset = 20.0
            make.top.equalTo(titleView.superview!).offset(topOffset)
            make.centerX.equalTo(titleView.superview!)
        })
        
        let accountView = self.accountView()
        mainView.addSubview(accountView)
        accountView.snp_makeConstraints(closure: { (make) -> Void in
            let topOffset = 20.0
            make.top.equalTo(titleView.snp_bottom).offset(topOffset)
            make.leading.equalTo(accountView.superview!).offset(10)
            make.trailing.equalTo(accountView.superview!).offset(-10)
            make.height.equalTo(30)
            
        })
        
        let pwdView = self.passwordView()
        mainView.addSubview(pwdView)
        pwdView.snp_makeConstraints(closure: { (make) -> Void in
            let topOffset = 20
            make.top.equalTo(accountView.snp_bottom).offset(topOffset)
            make.height.leading.trailing.equalTo(accountView)
        })
        
        let pwdItemView = self.passwordItemView()
        mainView.addSubview(pwdItemView)
        pwdItemView.snp_makeConstraints(closure: { (make) -> Void in
            let topOffset = 20
            make.height.leading.trailing.equalTo(pwdView)
            make.top.equalTo(pwdView.snp_bottom).offset(topOffset)
        })
        
        let buttonView = self.confirmAndRegisterView()
        mainView.addSubview(buttonView)
        buttonView.snp_makeConstraints(closure: { (make) -> Void in
            let topOffset = 20
            make.height.leading.trailing.equalTo(pwdView)
            make.top.equalTo(pwdItemView.snp_bottom).offset(topOffset)
        })
        
    }
    
    //MARK: - LoginViewController UI Creation
    func topTitle() -> UIView {
        let view = UIView()
        
        let title = UILabel()
        if let dict = uiContentDictionary() {
            title.text = dict["Title"] as? String
            title.font = title.font.fontWithSize(30)
        }
        
        view.addSubview(title)
        title.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(title.superview!)
            make.centerX.equalTo(title.superview!)
            make.height.equalTo(title.superview!)
        })
        
        return view;
    }
    
    func accountView() -> UIView {
        let view = UIView()
        accountFiled = UITextField()
        let dict:Dictionary<String, AnyObject>! = uiContentDictionary()
        accountFiled.placeholder = dict["AccountHint"] as? String
        accountFiled.borderStyle = .RoundedRect
        
        view.addSubview(accountFiled)
        accountFiled.snp_makeConstraints(closure: { (make) -> Void in
            make.top.bottom.left.right.equalTo(accountFiled.superview!)
        })
        
        return view
    }
    
    func passwordView() -> UIView {
        let view = UIView()
        
        pwdField = UITextField()
        let dict:Dictionary<String, AnyObject>! = uiContentDictionary()
        pwdField.placeholder = dict["PwdHint"] as? String
        pwdField.borderStyle = .RoundedRect
        pwdField.secureTextEntry = true
        
        view.addSubview(pwdField)
        pwdField.snp_makeConstraints(closure: { (make) -> Void in
            make.top.bottom.left.right.equalTo(pwdField.superview!)
        })
        
        return view
    }
    
    func passwordItemView() -> UIView {
        let view = UIView()
        
        let switchBtn = UISwitch()
        switchBtn.on = true
        if let resourcePath = getResourceBundlePath() {
            switchBtn.onImage = UIImage(contentsOfFile: resourcePath+"/check.png")
            switchBtn.offImage = UIImage(contentsOfFile: resourcePath+"/uncheck.png")
        }
        
        view.addSubview(switchBtn)
        switchBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.left.top.equalTo(switchBtn.superview!)
            
        })
        
        let savePwdLbl = UILabel()
        if let dict = uiContentDictionary() {
            savePwdLbl.text = dict["SavePwd"] as? String
        }
        
        view.addSubview(savePwdLbl)
        savePwdLbl.snp_makeConstraints(closure: { (make) -> Void in
            let offset = 10.0
            make.left.equalTo(switchBtn.snp_right).offset(offset)
            make.centerY.equalTo(switchBtn.snp_centerY)
        })
        
        let forgetPwdLbl = UILabel()
        if let dict = uiContentDictionary() {
            forgetPwdLbl.text = dict["ForgetPwd"] as? String
        }
        
        view.addSubview(forgetPwdLbl)
        forgetPwdLbl.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(forgetPwdLbl.superview!)
            make.centerY.equalTo(savePwdLbl.snp_centerY)
        })
        
        return view
    }
    
    func confirmAndRegisterView() -> UIView {
        let view = UIView()
        let resourcePath = getResourceBundlePath()
        
        let loginBtn = UIButton()
        loginBtn.addTarget(self, action: #selector(loginAction), forControlEvents: .TouchUpInside)
        if let uiInfo = uiContentDictionary() {
            loginBtn.setTitle(uiInfo["Login"] as? String, forState: .Normal)
            
            let bg = UIImage(contentsOfFile: resourcePath!+"/btn_bg.png")?.resizableImageWithCapInsets(UIEdgeInsets(top: 4, left: 14, bottom: 28, right: 17), resizingMode: .Stretch)
            loginBtn.setBackgroundImage(bg, forState: .Normal)
        }
//        view.backgroundColor = UIColor.blueColor()
        view.layer.cornerRadius = 5.0
        
        view.addSubview(loginBtn)
        loginBtn.snp_makeConstraints(closure: { (make) -> Void in
            let offset = 10
            make.left.top.height.equalTo(loginBtn.superview!)
            make.width.equalTo(loginBtn.superview!).dividedBy(2).offset(-offset)
        })
        
        let regBtn = UIButton()
        regBtn.addTarget(self, action: #selector(registrationAction), forControlEvents: .TouchUpInside)
        if let uiInfo = uiContentDictionary() {
            regBtn.setTitle(uiInfo["Register"] as? String, forState: .Normal)
            let bg = UIImage(contentsOfFile: resourcePath!+"/btn_bg.png")?.resizableImageWithCapInsets(UIEdgeInsets(top: 4, left: 14, bottom: 28, right: 17), resizingMode: .Tile)
            regBtn.setBackgroundImage(bg, forState: .Normal)
            
        }
        
        view.addSubview(regBtn)
        regBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.right.top.height.equalTo(regBtn.superview!)
            make.width.equalTo(regBtn.superview!).dividedBy(2).offset(-10)
        })
        
        
        return view
    }
    
    //MARK: - LoginViewController Utils
    func uiContentDictionary() -> Dictionary<String, AnyObject>? {
        let uiContentPath:String! = NSBundle.mainBundle().pathForResource("UIContent", ofType: "plist")
        let dictionary = NSDictionary(contentsOfFile: uiContentPath)
        return (dictionary as? Dictionary<String, AnyObject>)
    }
    
    func getResourceBundlePath() -> String? {
        return NSBundle.mainBundle().pathForResource("resource", ofType: "bundle")
    }
    
    func resignAllFirstResponder() {
        self.accountFiled.resignFirstResponder()
        self.pwdField.resignFirstResponder()
    }
    
    
    //MARK: - LoginViewController Item Respond
    func tapGesture() {
        self.resignAllFirstResponder()
    }
    
    func loginAction() {
        self.resignAllFirstResponder()
        
        if self.delegate != nil {
            self.delegate?.login("", password: "")
        }
        
    }
    
    func registrationAction() {
        self.resignAllFirstResponder()
    }
    
}





























