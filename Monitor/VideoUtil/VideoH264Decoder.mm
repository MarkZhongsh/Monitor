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
#import "NaluUtil.h"

const uint8_t StartCode[4] = { 0, 0, 0, 1};
const uint32_t StartCodeLength = 4;
const int DataLength = 1024*128;

enum FrameType
{
    IFrame = 0, PFrame, BFrame, UnknownFrame = 99
};

@interface VideoH264DecoderPacket : NSObject

@property (nonatomic, assign) CVPixelBufferRef frame;
@property (nonatomic, assign) FrameType type;
@end

@implementation VideoH264DecoderPacket

@synthesize frame, type;

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
    
    BOOL finished;
    CVPixelBufferRef lastPFrame;
    NSMutableArray<VideoH264DecoderPacket *> *frameQueue;
    
    CADisplayLink *displayTimer;
    
}

@end

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}


@implementation VideoH264Decoder

@synthesize fileStream, videoDelegate;


-(id) init
{
    self = [super init];
    
    if(self)
    {
        decodeSession = NULL;
        
        bufSize = 0;
        bufferCap = 1024 * 1024;
        buffer = (uint8_t*) malloc(bufferCap);
        memset(buffer, 0, bufferCap);
        
        sps = (uint8_t*) malloc(sizeof(uint8_t)*1024);
        memset(sps, 0, sizeof(uint8_t)*1024);
        spsSize = 0;
        
        pps = (uint8_t*) malloc(sizeof(uint8_t)*1024);
        memset(pps, 0, sizeof(uint8_t)*1024);
        ppsSize = 0;
        
//        fileStream = [[VideoFileStream alloc] init];
        fileStream = [[VideoNetworkStream alloc] init];
        videoDelegate = nil;
        finished = NO;
        
        lastPFrame = NULL;
        frameQueue = [[NSMutableArray alloc] init];
        
        displayTimer = NULL;
    }

    return self;
}

-(BOOL) initDecoder
{
    if(decodeSession)
        return YES;
    if(decodeSession)
    {
        VTDecompressionSessionInvalidate(decodeSession);
        decodeSession = NULL;
    }
    
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
        
        CFRelease(attrs);
    }
    return YES;
}

-(BOOL) open:(NSString *)path
{
    [self.fileStream openAddr:@"192.168.6.186" port:4000];
    return YES;
//    return [self.fileStream open:path];
}

-(BOOL) startDecode
{
    if(displayTimer == NULL)
    {
        displayTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(decode)];
        displayTimer.paused = NO;
//        displayTimer.frameInterval = 2;
        displayTimer.preferredFramesPerSecond = 15;
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        [displayTimer addToRunLoop:runloop forMode:NSRunLoopCommonModes];
        
    }
    
    displayTimer.paused = NO;
//    UITextField
    
    return YES;
}

-(void) stopDecode
{
    displayTimer.paused = YES;
}

-(void) decode
{
    NSUInteger readBytes = [self.fileStream getStream:buffer+bufSize size:bufferCap-bufSize];
    if(readBytes <= 0 && bufSize <= 0)
        return;
    
    bufSize+= readBytes;
    
    //        if( memcmp(KStartCode, buffer, StartCodeLength) != 0)
    //        {
    //            return ;
    //        }
    
    uint8_t data[DataLength] = "";
    NSInteger nalUnitSize = 0;
    nalUnitSize = [self separateNalUnit:data];
    if(nalUnitSize != 0)
    {
        [self dataFilter:data size:nalUnitSize];
    }
    
}

-(NSInteger) separateNalUnit:(uint8_t *) data
{
    //start code length + nal type length
    if( bufSize > StartCodeLength+1)
    {
        long startCodeIndex = [self sundayFindSubString:buffer+StartCodeLength strLen:bufSize-StartCodeLength subStr:StartCode subStrLen:StartCodeLength];
        if(startCodeIndex >= 0)
        {
            long size = startCodeIndex + StartCodeLength;
            memcpy(data, buffer, size);
            memmove(buffer, buffer+size, bufSize-size);
            bufSize -= size;
            return size;
        }
    }
    return 0;
}


-(long) sundayFindSubString:(const uint8_t *) str strLen:(int) strLen subStr:(const uint8_t*) subStr subStrLen:(int) subStrLen
{

    if( strLen <= 0 || subStrLen <= 0)
        return -1;
    
    long strInx = 0, subStrInx = 0;
    long nextCompare = subStrLen;
    
    while(strInx < strLen && subStrInx < subStrLen)
    {
        if(memcmp(str+strInx, subStr+subStrInx, sizeof(uint8_t)) == 0)
        {
            strInx++;
            subStrInx++;
        }
        else if(nextCompare < strLen)
        {
            long i;
            //搜索子串中是否有该字符
            for(i=subStrLen-1; i >= 0; i--)
            {
                
                if(memcmp(subStr+i, str+nextCompare, sizeof(uint8_t)) == 0)
                {
                    subStrInx = 0;
                    long move = subStrLen-i;
                    strInx = nextCompare-i;
                    nextCompare += move;
                    break;
                }
            }
            
            //子串中无下一个字符
            if(i < 0)
            {
                strInx = nextCompare+1;
                subStrInx = 0;
                nextCompare += subStrLen+1;
            }
            
        }
        else
            return -1;
    }
    
    if(subStrInx == subStrLen)
        return strInx-subStrInx;
    
    return -1;
}

-(void) dataFilter:(uint8_t*) data size:(NSInteger) size
{
    
    
    Slice slice = Slice((uint8*)(data+StartCodeLength+1), (uint8*)(data+size-1));
    int frame_type = slice.getSliceHeader();
    frame_type = slice.getSliceHeader();
    NSLog(@"frame_type: %d", frame_type);
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
            memset(sps, 0, 1024);
            memcpy(sps, data+4, spsSize);
            break;
        case 0x08:
            ppsSize = size-4;
            memset(pps, 0, 1024);
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
    Slice slice = Slice((uint8*)(data+StartCodeLength+1), (uint8*)(data+size-1));
    int frame_type = slice.getSliceHeader();
    frame_type = slice.getSliceHeader();
    FrameType type;
    switch (frame_type) {
        case 2: case 4:
        case 7: case 9:
            type = IFrame;
            NSLog(@"I Frame");
            break;
        case 0:case 3:
        case 5:case 8:
            type = PFrame;
            NSLog(@"frame_type: %d",frame_type);
            NSLog(@"P Frame");
            break;
        case 1: case 6:
            type = BFrame;
            NSLog(@"B Frame");
            break;
        default:
            type = UnknownFrame;
            break;
    }
    
    CVPixelBufferRef output = [self getLastPiexelByFrameType:type currentFrame:decodePixel];
//    CVPixelBufferRef output = decodePixel;
    if(self.videoDelegate && output != NULL)
    {
        [self.videoDelegate videoDecodeCallback:output];
        CVPixelBufferRelease(output);
    }
}

-(CVPixelBufferRef) getLastPiexelByFrameType:(FrameType) type currentFrame:(CVPixelBufferRef) frame
{
    CVPixelBufferRef lastFrame = frame;
    
    VideoH264DecoderPacket *lastPacket = NULL;
    if( [frameQueue count] > 0)
    {
        lastPacket = [frameQueue objectAtIndex:0];
//        [frameQueue removeObject:lastPacket];
    }
    
    switch (type) {
        //I frame
        case IFrame:
            if(lastPacket != NULL)
            {
                lastFrame = lastPacket.frame;
                lastPacket.frame = frame;
                lastPacket.type = IFrame;
            }
            break;
        //P frame
        case PFrame:
            if(lastPacket != NULL)
            {
                lastFrame = lastPacket.frame;
                lastPacket.frame = frame;
                lastPacket.type = PFrame;
            }
            else
            {
                VideoH264DecoderPacket *packet = [[VideoH264DecoderPacket alloc] init];
                lastPacket.frame = frame;
                lastPacket.type = PFrame;
                [frameQueue addObject:packet];
            }
            break;
        //B Frame
        case BFrame:
            lastFrame = frame;
            break;
            
        default:
            break;
    }
    return lastFrame;
}

-(void) clear
{
    finished = YES;
    
    [self stopDecode];
    
    SAFE_FREE(sps);
    SAFE_FREE(pps);
    SAFE_FREE(buffer);
    
    VTDecompressionSessionInvalidate(decodeSession);
    SAFE_CFRELEASE(description);
    SAFE_CFRELEASE(lastPFrame);
    
    if(self.fileStream)
       [self.fileStream close];
    
    [frameQueue removeAllObjects];
    frameQueue = nil;
    
    [displayTimer invalidate];
    displayTimer = nil;
}

-(void) dealloc
{
    
}


@end













