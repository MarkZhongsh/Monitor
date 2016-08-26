//
//  VideoH264Decoder.swift
//  Monitor
//
//  Created by suihong on 16/8/16.
//  Copyright © 2016年 suihong. All rights reserved.
//

import Foundation
import VideoToolbox


class H264Packet {
    var buffer: UnsafeMutablePointer<UInt8>? = nil
    var size: Int = 0
}

class VideoH264Decoder {
    
    var sps: UnsafeMutablePointer<UInt8> = nil
    var spsSize:UnsafePointer<Int> = nil
    var pps: UnsafeMutablePointer<UInt8> = nil
    var ppsSize: UnsafePointer<Int>  = nil
        
    private var decoderSession: VTDecompressionSessionRef? = nil
    private var decoderDescription: CMVideoFormatDescriptionRef? = nil
        
    func initDecoder() -> Bool {
        if decoderSession != nil {
            return true
        }
        
        let paramterSetPoints = [sps, pps]
        let paramterSetPointsPointer = UnsafePointer<UnsafePointer<UInt8>>(paramterSetPoints)
        let paramterSetSizes = [spsSize, ppsSize]
        let paramterSetSizesPointer = UnsafePointer<Int>(paramterSetSizes)
        
        var status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, paramterSetPointsPointer, paramterSetSizesPointer, 4, &decoderDescription)
        
        if status == noErr {
            var attrs: CFDictionaryRef? = nil
            
            let keys = [kCVPixelBufferPixelFormatTypeKey]
            let keysPointer = UnsafeMutablePointer<UnsafePointer<Void>>(keys)
            var v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            let values = [CFNumberCreate(nil, .SInt32Type, &v)]
            let valuesPointer = UnsafeMutablePointer<UnsafePointer<Void>>(values)
            
            attrs = CFDictionaryCreate(nil, keysPointer, valuesPointer, 1, nil, nil)
            
            var callBackRecord = VTDecompressionOutputCallbackRecord()
            callBackRecord.decompressionOutputCallback = nil
            callBackRecord.decompressionOutputRefCon = nil
            
            status = VTDecompressionSessionCreate(kCFAllocatorDefault, decoderDescription!, nil, attrs, &callBackRecord, &decoderSession)
            
        }
        else {
            print("IOS8VT: reset decoder session failed status=%d", status)
            return false
        }
        
        return true
    }
    
    func clear() {
        if decoderSession != nil {
            VTDecompressionSessionInvalidate(decoderSession!)
            decoderSession = nil
        }
        
        if decoderDescription != nil {
            decoderDescription = nil
        }
        
        free(sps)
        free(pps)
        
        sps.memory = 0
        pps.memory = 0
        
        
    }
    
    func decode(packet: H264Packet) -> CVPixelBufferRef? {
        
        var outputPixelBuffer:CVPixelBufferRef? = nil
        var blockBuff: CMBlockBufferRef? = nil
        
        var status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                        packet.buffer!,
                                                        packet.size,
                                                        kCFAllocatorNull,
                                                        nil,
                                                        0,
                                                        packet.size,
                                                        0,
                                                        &blockBuff)
        if status == kCMBlockBufferNoErr {
            var sampleBuff: CMSampleBufferRef? = nil
            
            let sampleSize = [packet.size]
            status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuff, decoderDescription!, 1, 0, nil, 1, sampleSize, &sampleBuff)
            
            if status == kCMBlockBufferNoErr && sampleBuff != nil {
                let flags:VTDecodeFrameFlags = ._EnableAsynchronousDecompression
                var flagsOut:VTDecodeInfoFlags = .Asynchronous
                let decodeStatus = VTDecompressionSessionDecodeFrame(decoderSession!, sampleBuff!, flags, &outputPixelBuffer, &flagsOut)
                
                if decodeStatus == kVTInvalidSessionErr  {
                    print("IOS8VT: Invalid session, reset decoder session");
                } else if decodeStatus == kVTVideoDecoderBadDataErr  {
                    print("IOS8VT: decode failed status=%d(Bad data)", decodeStatus);
                } else if decodeStatus != noErr {
                    print("IOS8VT: decode failed status=%d", decodeStatus);
                }
                
                
            }
        }

        return outputPixelBuffer
    }
}





































