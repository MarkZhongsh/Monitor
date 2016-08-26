//
//  VideoH264Decoder.m
//  Monitor
//
//  Created by suihong on 16/8/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VideoH264Decoder.h"
#import "VideoStream.h"

const uint8_t KStartCode[4] = { 0, 0, 0, 1};

@implementation VideoH264DecoderPacket



@end


@interface VideoH264Decoder()
{
    uint8_t *buffer;
    int bufSize;
    int bufferCap;
    
    uint8_t *sps;
    NSInteger spsSize;
    uint8_t *pps;
    NSInteger ppsSize;
    
    VTDecompressionSessionRef decodeSession;
    CMVideoFormatDescriptionRef description;
}

@end

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}


@implementation VideoH264Decoder

@synthesize fileStream, videoDelegate, readyToDecode;


-(id) init
{
    self = [super init];
    
    if(self)
    {
        bufSize = 0;
        bufferCap = 512 * 1024;
        buffer = (uint8_t*) malloc(bufferCap);
        
        fileStream = [[VideoFileStream alloc] init];
        videoDelegate = nil;
        readyToDecode = NO;
    }
    
    return self;
}

-(BOOL) initDecoder
{
    if(decodeSession)
        return YES;
    
    const uint8_t * const parameterSetPointers[2] = { sps, pps };
    const size_t parameterSetSize[2] = { spsSize, ppsSize };
    
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSize, 4, &description);
    
    if(status == noErr)
    {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = {kCVPixelBufferPixelFormatTypeKey};
        uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *value[] = {CFNumberCreate(NULL, kCFNumberSInt32Type, &v)};
        attrs = CFDictionaryCreate(NULL, keys, value, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callbackRecord;
        callbackRecord.decompressionOutputCallback = didDecompress;
        callbackRecord.decompressionOutputRefCon = NULL;
        
        status = VTDecompressionSessionCreate(kCFAllocatorDefault, description, NULL, attrs, &callbackRecord, &decodeSession);
        if (status == noErr) {
            readyToDecode = YES;
        }
        
        CFRelease(attrs);
    }
    return YES;
}

-(BOOL) open:(NSString *)path
{
    return [self.fileStream open:path];
}

-(BOOL) startDecode
{
    while(YES)
    {
        NSUInteger readBytes = [self.fileStream getStream:buffer+bufSize size:bufferCap-bufSize];
        if(readBytes <= 0 && bufSize <= 0)
            break;
        
        bufSize+= readBytes;
        
        
        if( memcmp(KStartCode, buffer, 4) != 0)
        {
            return NO;
        }
        
        
        if( bufSize > 5)
        {
            uint8_t *bufBegin = buffer + 4;
            uint8_t *bufEnd = buffer + bufSize;
            while(bufBegin != bufEnd)
            {
                if(*bufBegin == 0x01)
                {
                    if(memcmp(bufBegin-3, KStartCode, 4) == 0)
                    {
                        NSInteger pSize = bufBegin-buffer-3;
                        uint8_t *data = malloc(pSize);
                        memcpy(data, buffer, pSize);
                        memmove(buffer, buffer+pSize, bufSize-pSize);
                        bufSize -= pSize;
                        //[self decode:data size:pSize];
                        [self dataFilter:data size:pSize];
                        free(data);
                        break;
                    }
                }
                bufBegin++;
            }
        }
    }
    
    return YES;
}

-(void) stopDecode
{
    
}

-(void) dataFilter:(uint8_t*) data size:(NSInteger) size
{
    
    uint32_t nalSize = (uint32_t)size-4;
    uint8_t *nalSizePtr = (uint8_t*)&nalSize;
    data[0] = *(nalSizePtr+3);
    data[1] = *(nalSizePtr+2);
    data[2] = *(nalSizePtr+1);
    data[3] = *(nalSizePtr+0);
    
    int nalType = data[4] & 0x1f;
    switch (nalType) {
        case 0x05:
            NSLog(@"this is IDR frame type");
            if([self initDecoder])
                [self decode:data size:size];
            NSLog(@"size is %ld", (long)size);
            break;
        case 0x07:
            NSLog(@"this is sps type");
            spsSize = size-4;
            if(sps)
                free(sps);
            sps = malloc(spsSize);
            memcpy(sps, data+4, spsSize);
            NSLog(@"size is %ld", (long)size);
            break;
        case 0x08:
            NSLog(@"this is psp type");
            ppsSize = size-4;
            if(pps)
                free(pps);
            pps = malloc(ppsSize);
            memcpy(pps, data+4, ppsSize);
            NSLog(@"size is %ld", (long)size);
            break;
        default:
            NSLog(@"this is B/P frame");
            [self decode:data size:size];
            NSLog(@"size is %ld", (long)size);
            break;
    }
}

-(void) decode:(uint8_t *) data size:(NSInteger) size
{
    CVPixelBufferRef outputPixel = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, (void*)data, size, kCFAllocatorNull, NULL, 0, size, 0, &blockBuffer);
    
    if(status == kCMBlockBufferNoErr)
    {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleArraySize[] = {size};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, description, 1, 0, NULL, 1, sampleArraySize, &sampleBuffer);
        
        
        
        if(status == kCMBlockBufferNoErr && sampleBuffer)
        {
            
            
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags outFlags = 0;
            
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(decodeSession, sampleBuffer, flags, &outputPixel, &outFlags);
            if(decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session, reset decoder session");
            } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
            } else if(decodeStatus != noErr) {
                NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
            }
            
            CFRelease(sampleBuffer);
        }
        CFRelease(blockBuffer);
    }
    
    if(self.videoDelegate)
    {
        [self.videoDelegate videoDecodeCallback:outputPixel];
    }
    //return outputPixel;
}

-(void) dealloc
{
    [self stopDecode];
    
    free(buffer);
}


@end













