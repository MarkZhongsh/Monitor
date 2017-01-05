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
    func login(_ account: String, password: String)
}

class LoginViewController : UIViewController, UITextFieldDelegate {
    
    var pwdField: UITextField!
    var accountFiled: UITextField!
    
    var delegate: LoginDelegate?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
//        self.navigationItem.titleView = nil
//        self.navigationItem.title = "";
        
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
        if let dict = MonitorUtil.UiContentDictionary() {
            title.text = dict["Title"] as? String
            title.font = title.font.withSize(30)
        }
        
//        self.navigationItem.title = title.text
        
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
        let dict:Dictionary<String, AnyObject>! = MonitorUtil.UiContentDictionary()
        accountFiled.placeholder = dict["AccountHint"] as? String
        accountFiled.borderStyle = .roundedRect
        accountFiled.returnKeyType = .next
        accountFiled.delegate = self
        
        view.addSubview(accountFiled)
        accountFiled.snp_makeConstraints(closure: { (make) -> Void in
            make.top.bottom.left.right.equalTo(accountFiled.superview!)
        })
        
        return view
    }
    
    func passwordView() -> UIView {
        let view = UIView()
        
        pwdField = UITextField()
        let dict:Dictionary<String, AnyObject>! = MonitorUtil.UiContentDictionary()
        pwdField.placeholder = dict["PwdHint"] as? String
        pwdField.borderStyle = .roundedRect
        pwdField.isSecureTextEntry = true
        pwdField.delegate = self
        pwdField.returnKeyType = .done
        
        view.addSubview(pwdField)
        pwdField.snp_makeConstraints(closure: { (make) -> Void in
            make.top.bottom.left.right.equalTo(pwdField.superview!)
        })
        
        return view
    }
    
    func passwordItemView() -> UIView {
        let view = UIView()
        
        let switchBtn = UISwitch()
        switchBtn.isOn = true
        if let resourcePath = MonitorUtil.GetResourceBundlePath() {
            switchBtn.onImage = UIImage(contentsOfFile: resourcePath+"/check.png")
            switchBtn.offImage = UIImage(contentsOfFile: resourcePath+"/uncheck.png")
        }
        
        view.addSubview(switchBtn)
        switchBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.left.top.equalTo(switchBtn.superview!)
            
        })
        
        let savePwdLbl = UILabel()
        if let dict = MonitorUtil.UiContentDictionary() {
            savePwdLbl.text = dict["SavePwd"] as? String
        }
        
        view.addSubview(savePwdLbl)
        savePwdLbl.snp_makeConstraints(closure: { (make) -> Void in
            let offset = 10.0
            make.left.equalTo(switchBtn.snp_right).offset(offset)
            make.centerY.equalTo(switchBtn.snp_centerY)
        })
        
        let forgetPwdLbl = UILabel()
        if let dict = MonitorUtil.UiContentDictionary() {
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
        let resourcePath = MonitorUtil.GetResourceBundlePath()
        
        let loginBtn = UIButton()
        loginBtn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        if let uiInfo = MonitorUtil.UiContentDictionary() {
            loginBtn.setTitle(uiInfo["Login"] as? String, for: UIControlState())
            
            let bg = UIImage(contentsOfFile: resourcePath!+"/btn_bg.png")?.resizableImage(withCapInsets: UIEdgeInsets(top: 4, left: 14, bottom: 28, right: 17), resizingMode: .stretch)
            loginBtn.setBackgroundImage(bg, for: UIControlState())
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
        regBtn.addTarget(self, action: #selector(registrationAction), for: .touchUpInside)
        if let uiInfo = MonitorUtil.UiContentDictionary() {
            regBtn.setTitle(uiInfo["Register"] as? String, for: UIControlState())
            let bg = UIImage(contentsOfFile: resourcePath!+"/btn_bg.png")?.resizableImage(withCapInsets: UIEdgeInsets(top: 4, left: 14, bottom: 28, right: 17), resizingMode: .tile)
            regBtn.setBackgroundImage(bg, for: UIControlState())
            
        }
        
        view.addSubview(regBtn)
        regBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.right.top.height.equalTo(regBtn.superview!)
            make.width.equalTo(regBtn.superview!).dividedBy(2).offset(-10)
        })
        
        
        return view
    }
    
    //MARK: - LoginViewController Utils
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
        
        self.delegate?.login("", password: "")
        
        let channelCtrl = ChannelsController()
        if navigationController != nil {
            navigationController!.pushViewController(channelCtrl, animated: true)
        }
        else {
            present(channelCtrl, animated: true, completion: nil)
        }
//        let videoViewCtrl = VideoViewController()
//        present(videoViewCtrl, animated: true, completion: nil)
        
    }
    
    func registrationAction() {
        self.resignAllFirstResponder()
    }
    
    //MARK: - UITextFieldDelegate 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            textField.resignFirstResponder()
            self.pwdField.becomeFirstResponder()
//            textField.next
        }
        else if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        
        return true
    }
}





























