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

#import "Slice.h"

const uint8_t KStartCode[4] = { 0, 0, 0, 1};
const uint8_t StartCodeLength = 4;

@implementation VideoH264DecoderPacket

@end


@interface VideoH264Decoder()
{
    uint8_t *buffer;
    int bufSize;
    int bufferCap;
    
    uint8_t *sps;
    unsigned long spsSize;
    uint8_t *pps;
    unsigned long ppsSize;
    
    VTDecompressionSessionRef decodeSession;
    CMVideoFormatDescriptionRef description;
    
    BOOL isStop;
    CVPixelBufferRef lastPFrame;
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
        isStop = NO;
        lastPFrame = NULL;
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
    while(!isStop)
    {
        NSUInteger readBytes = [self.fileStream getStream:buffer+bufSize size:bufferCap-bufSize];
        if(readBytes <= 0 && bufSize <= 0)
            break;
        
        bufSize+= readBytes;
        
        if( memcmp(KStartCode, buffer, StartCodeLength) != 0)
        {
            return NO;
        }
        
        NSInteger nalUnitSize = 0;
        uint8_t *nalUnit = [self separateNalUnit:&nalUnitSize];
        if(nalUnit != NULL && nalUnitSize != 0)
        {
            [self dataFilter:nalUnit size:nalUnitSize];
        }
        
        usleep(16666);
    }
    
    return YES;
}

-(void) stopDecode
{
    isStop = YES;
}

-(uint8_t *) separateNalUnit:(NSInteger *) size
{
    //start code length + nal type length
    if( bufSize > StartCodeLength+1)
    {
        uint8_t *bufBegin = buffer + StartCodeLength;
        uint8_t *bufEnd = buffer + bufSize;
        //search for next start code
        while(bufBegin != bufEnd)
        {
            if(*bufBegin == 0x01)
            {
                if(memcmp(bufBegin-(StartCodeLength-1), KStartCode, StartCodeLength) == 0)
                {
                    *size = bufBegin-buffer-3;
                    uint8_t *data = (uint8_t *)malloc(*size);
                    memcpy(data, buffer, *size);
                    memmove(buffer, buffer+*size, bufSize-*size);
                    bufSize -= *size;
                    return data;
                }
            }
            bufBegin++;
        }
    }
    return NULL;
}


-(void) dataFilter:(uint8_t*) data size:(NSInteger) size
{
    // hard decoder can only decode mp4 formart, so we should replace the start code with nal's length
    uint32_t nalSize = (uint32_t)size-4;
    uint8_t *nalSizePtr = (uint8_t*)&nalSize;
    data[0] = *(nalSizePtr+3);
    data[1] = *(nalSizePtr+2);
    data[2] = *(nalSizePtr+1);
    data[3] = *(nalSizePtr+0);
    
    int nalType = data[4] & 0x1f;
    switch (nalType) {
        case 0x05:
            if([self initDecoder])
                [self decode:data size:size];
            break;
        case 0x07:
            spsSize = size-4;
            SAFE_FREE(sps);
            sps = (uint8_t*)malloc(spsSize);
            memcpy(sps, data+4, spsSize);
            break;
        case 0x08:
            ppsSize = size-4;
            SAFE_FREE(pps);
            pps = (uint8_t*)malloc(ppsSize);
            memcpy(pps, data+4, ppsSize);
            break;
        default:
            [self decode:data size:size];
            break;
    }
}

-(void) decode:(uint8_t *) data size:(unsigned long) size
{
    CVPixelBufferRef decodePixel = NULL;
    
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
            
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(decodeSession, sampleBuffer, flags, &decodePixel, &outFlags);
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
    
    //start code length + nalType length = 5
    CVPixelBufferRef output = decodePixel;
    Slice slice = Slice((uint8*)(data+StartCodeLength+1), (uint8*)(data+size-1));
    int frame_type = slice.getSliceHeader();
    frame_type = slice.getSliceHeader();
    switch (frame_type) {
        case 5:
        case 0:
        case 8:
            output = lastPFrame;
            lastPFrame = decodePixel;
            break;
            
        default:
            break;
    }
    
    if(self.videoDelegate && output != NULL)
    {
        [self.videoDelegate videoDecodeCallback:output];
    }
}

-(void) clear
{
    [self stopDecode];
    
    SAFE_FREE(sps);
    SAFE_FREE(pps);
    SAFE_FREE(buffer);
    
    VTDecompressionSessionInvalidate(decodeSession);
    SAFE_CFRELEASE(description);
    SAFE_CFRELEASE(lastPFrame);
    
}

-(void) dealloc
{
}


@end













