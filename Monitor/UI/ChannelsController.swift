//
//  ChannelsController.swift
//  Monitor
//
//  Created by suihong on 16/12/29.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation

class ChannelsController : UICollectionViewController
{
    let ITEM_IDNF = "CHANNEL_ITEM"
    
    required init () {
        
        let layout = UICollectionViewFlowLayout.init()
        let screenBound = UIScreen.main.bounds
        layout.itemSize = CGSize(width: screenBound.width/2-2, height: screenBound.width/2-2)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        super.init(collectionViewLayout: layout)
        
        self.collectionView?.register(ChannelItem.classForCoder(), forCellWithReuseIdentifier: ITEM_IDNF)
        
        self.navigationItem.title = "测试频道"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    
    //MARK: - DataSource
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ITEM_IDNF, for: indexPath)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    //MARK: - Delegate
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let videoCtrl = VideoViewController()
        
        present(videoCtrl, animated: true, completion: nil)
    }
    
    
    
    
}
