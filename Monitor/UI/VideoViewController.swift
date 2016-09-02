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
import AVFoundation


class VideoViewController: UIViewController, VideoH264DecoderDelegate {
    var videoTitle: String? = "大爷般的Swift工工工工工工"
    
    private var topView: UIView!
    private var bottomView: UIView!
    private var displayLayer: AAPLEAGLLayer!
    private var diaplayImgView: UIImageView!
    
    private var isPlaying: Bool = false
    private var isAnimating: Bool = false
    
    private var videoDecoder: VideoH264Decoder!
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
//        videoView.backgroundColor = UIColor.brownColor()
        view.insertSubview(videoView, atIndex: 0)
        videoView.snp_makeConstraints(closure: { (make) -> Void in
            make.leading.trailing.equalTo(videoView.superview!)
            make.top.bottom.equalTo(videoView.superview!)
        })
        
    }
    
    override func viewDidLayoutSubviews() {
        if displayLayer != nil && CGRectIsEmpty(displayLayer.frame) == true {
            let layer = self.view.layer
            let bounds = CGRectMake(layer.bounds.origin.x, layer.bounds.origin.y, layer.bounds.width, layer.bounds.height)
            displayLayer.bounds = bounds
            displayLayer.position = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds))
            
        }
    }
    
    private func createTopView() -> UIView {
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
        title.text = videoTitle
        title.textColor = UIColor.blackColor()
        title.textAlignment = .Center
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
    
    private func createBottomView() -> UIView {
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
    
    private func createVideoView() -> UIView {
        let view = UIView()
        
        let tapVideoGes = UITapGestureRecognizer(target: self, action: #selector(tapVideoView))
        view.addGestureRecognizer(tapVideoGes)
        
        displayLayer = AAPLEAGLLayer(frame: UIScreen.mainScreen().bounds)
        view.layer.addSublayer(displayLayer)
        
        videoDecoder = VideoH264Decoder()
        let videoPath = NSBundle.mainBundle().pathForResource("mtv", ofType: "h264")
        videoDecoder.open(videoPath)
        videoDecoder.videoDelegate = self
        
        return view;
    }
    
    //MARK: - VideoViewController Actions
    @objc private func backButtonClicked() {
        videoDecoder.clear()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func playButtonClicked(playBtn btn: AnyObject) {
        let playBtn = btn as! UIButton
        isPlaying = !isPlaying
        var playBtnImg: UIImage!
        let resourcePath = MonitorUtil.GetResourceBundlePath()
        if isPlaying == true {
            self.videoDecoder.startDecode();
            playBtnImg = UIImage(contentsOfFile: resourcePath!+"/pauseVideo.png")
        }
        else {
            self.videoDecoder.stopDecode();
            playBtnImg = UIImage(contentsOfFile: resourcePath!+"/playVideo.png")
        }
        
        playBtn.setBackgroundImage(playBtnImg, forState: .Normal)
    }
    
    @objc private func tapVideoView() {
        
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
    
    //MARK: - VideoH264Decoder Deleagte
    func videoDecodeCallback(pixelBuff: CVPixelBufferRef?) {
        if pixelBuff != nil {
            self.setVideoBuffer(pixelBuff!)
        }
    }
    
    //MARK: - Video Operation
    func setVideoBuffer(buffer: CVPixelBufferRef) {
        self.displayLayer.pixelBuffer = buffer
        
    }
}




















































