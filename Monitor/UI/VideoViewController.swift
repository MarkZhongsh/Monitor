//
//  VideoViewController.swift
//  Monitor
//
//  Created by suihong on 16/8/15.
//  Copyright © 2016年 suihong. All rights reserved.
//


import SnapKit
import Foundation
import UIKit


class VideoViewController: UIViewController  {
    var topView: UIView!
    var bottomView: UIView!
    
    var isPlaying: Bool = false
    var isAnimating: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        topView = createTopView()
        topView.backgroundColor = UIColor.redColor()
        view.addSubview(topView)
        topView.snp_makeConstraints(closure: { (make) -> Void in
            let time = 11
            make.top.leading.trailing.equalTo(topView.superview!)
            make.height.equalTo(topView.superview!).dividedBy(time)
        })
        
        bottomView = createBottomView()
        bottomView.backgroundColor = UIColor.blueColor()
        view.addSubview(bottomView)
        bottomView.snp_makeConstraints(closure: { (make) -> Void in
            let time = 11
            make.bottom.leading.trailing.equalTo(bottomView.superview!)
            make.height.equalTo(bottomView.superview!).dividedBy(time)
        })
        
        let videoView = createVideoView()
        videoView.backgroundColor = UIColor.brownColor()
        view.insertSubview(videoView, atIndex: 0)
        videoView.snp_makeConstraints(closure: { (make) -> Void in
            make.leading.trailing.equalTo(videoView.superview!)
            make.top.bottom.equalTo(videoView.superview!)
        })
        
    }
    
    func createTopView() -> UIView {
        let view = UIView()
        
        let backBtn = UIButton()
        let resourcePath = MonitorUtil.GetResourceBundlePath()
        let leftArrImg = UIImage(contentsOfFile: resourcePath!+"/leftArrow.png")
        backBtn.setImage(leftArrImg, forState: .Normal)
        backBtn.addTarget(self, action: #selector(backButtonClicked), forControlEvents: .TouchUpInside)
        view.addSubview(backBtn)
        backBtn.snp_makeConstraints(closure: { (make) -> Void in
            make.top.leading.bottom.equalTo(backBtn.superview!)
            make.height.equalTo(backBtn.snp_width)
        })
        
        let title = UILabel()
        title.text = "如果说这个标题变得很长很长会咋样呢我非常好奇啊"
        title.textColor = UIColor.blackColor()
        title.numberOfLines = 1
        title.lineBreakMode = .ByTruncatingTail
        view.addSubview(title)
        title.snp_makeConstraints(closure: { (make) -> Void in
            let time = 2
            make.centerX.centerY.equalTo(title.superview!)
            make.width.equalTo(title.superview!).dividedBy(time)
        })
        
        return view
    }
    
    func createBottomView() -> UIView {
        let view = UIView()
        
        let playBtn = UIButton()
        let resourcePath = MonitorUtil.GetResourceBundlePath()
        let playBtnImg = UIImage(contentsOfFile: resourcePath!+"/playVideo.png")
        playBtn.setBackgroundImage(playBtnImg, forState: .Normal)
        playBtn.addTarget(self, action: #selector(playButtonClicked(playBtn:)), forControlEvents: .TouchUpInside)
        view.addSubview(playBtn)
        playBtn.snp_makeConstraints(closure: { (make) -> Void in
            let offset = 2
            make.centerX.centerY.equalTo(playBtn.superview!)
            make.top.equalTo(playBtn.superview!).offset(offset)
            make.height.equalTo(playBtn.snp_width)
        })
        
        return view
    }
    
    func createVideoView() -> UIView {
        let view = UIView()
        
        let tapVideoGes = UITapGestureRecognizer(target: self, action: #selector(tapVideoView))
        view.addGestureRecognizer(tapVideoGes)
        
        return view;
    }
    
    //MARK: - VideoViewController Actions
    func backButtonClicked() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func playButtonClicked(playBtn btn: AnyObject) {
        let playBtn = btn as! UIButton
        isPlaying = !isPlaying
        var playBtnImg: UIImage!
        let resourcePath = MonitorUtil.GetResourceBundlePath()
        if isPlaying == true {
            playBtnImg = UIImage(contentsOfFile: resourcePath!+"/pauseVideo.png")
        }
        else {
            playBtnImg = UIImage(contentsOfFile: resourcePath!+"/playVideo.png")
        }
        
        playBtn.setBackgroundImage(playBtnImg, forState: .Normal)
    }
    
    func tapVideoView() {
        
        //若动画正在进行, 则直接返回
        if isAnimating == true {
            return
        }
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fillMode = kCAFillModeForwards
        fadeAnimation.delegate = self
        
        //设置透明度
        if topView.layer.opacity == 0 {
            fadeAnimation.fromValue = 0.0
            fadeAnimation.toValue = 1.0
            fadeAnimation.duration = 0.5
            
            topView.layer.opacity = 1.0
            bottomView.layer.opacity = 1.0
        }
        else {
            fadeAnimation.fromValue = 1.0
            fadeAnimation.toValue = 0.0
            fadeAnimation.duration = 0.8
            
            topView.layer.opacity = 0.0
            bottomView.layer.opacity = 0.0
        }
        
        topView.layer.addAnimation(fadeAnimation, forKey: "topFade")
        bottomView.layer.addAnimation(fadeAnimation, forKey: "bottomFade")
    }
    
    //MARK: - CAAnimation Delegate Selector
    override func animationDidStart(anim: CAAnimation) {
        isAnimating = true
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
    }
    
}




















