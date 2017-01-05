//
//  ChannelItem.swift
//  Monitor
//
//  Created by suihong on 17/1/4.
//  Copyright © 2017年 suihong. All rights reserved.
//

import Foundation
import SnapKit


class ChannelItem : UICollectionViewCell {
    var imgView:UIImageView
    var imgLabel:UILabel
    
    override init(frame: CGRect) {
        
        imgView = UIImageView()
        imgLabel = UILabel()
        
        super.init(frame: frame)
        
        let view = UIView()
        
        self.contentView.addSubview(view)
        view.snp_makeConstraints(closure: { (make) -> Void in
            make.top.bottom.left.right.equalTo(view.superview!)
        })
        
        view.addSubview(imgView)
        view.addSubview(imgLabel)
        
        imgView.snp_makeConstraints(closure: { (make) -> Void in
            make.top.left.right.equalTo(imgView.superview!)
            make.bottom.equalTo(imgLabel.snp_top)
        })
        
        imgLabel.snp_makeConstraints(closure: {(make) -> Void in
            make.left.right.bottom.equalTo(imgLabel.superview!)
            make.top.equalTo(imgView.snp_bottom)
        })
        
        let bundlePath = Bundle.main.path(forResource: "resource", ofType: "bundle")
        let bundle = Bundle(path: bundlePath!)
        imgView.image = UIImage(contentsOfFile: bundle!.path(forResource: "pauseVideo", ofType: "png")!)
        
        imgLabel.text = "hello"
        imgLabel.textAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
