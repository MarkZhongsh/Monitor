//
//  VideoStream.swift
//  Monitor
//
//  Created by suihong on 16/8/17.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation


class VideoStream {
    private var buffer: UnsafeMutablePointer<UInt8>?
    private var bufferSize: Int = 0
    
    func open(path: String) -> Bool {
        return false
    }
    
    func getStream(size: Int) -> (UnsafePointer<UInt8>, Int) {
        return (nil, -1)
    }
    
    
    
}


class VideoFileStream : VideoStream {
    
    private var fileStream: NSInputStream?
    
    override func open(path: String) -> Bool {
        
        fileStream = NSInputStream.init(fileAtPath: path)
        if fileStream == nil {
            return false
        }
        
        return true
    }
    
    override func getStream(size: Int) -> (UnsafePointer<UInt8>, Int) {
        
        
        
        return super.getStream(size)
    }
    
    
}





































