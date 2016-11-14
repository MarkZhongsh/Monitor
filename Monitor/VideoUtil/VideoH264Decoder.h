//
//  VideoH264Decoder.h
//  Monitor
//
//  Created by suihong on 16/8/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef VideoH264Decoder_h
#define VideoH264Decoder_h


#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

#import "VideoStream.h"

#define SAFE_FREE(x) if ((x)) { free((x)); (x) = NULL;}
#define SAFE_CFRELEASE(x) if ((x)) { CFRelease((x)); (x) = NULL;}



@protocol VideoH264DecoderDelegate <NSObject>

-(void) videoDecodeCallback:(CVPixelBufferRef) pixelBuff;

@end

@interface VideoH264Decoder : NSObject

@property (nonatomic, retain, readonly) VideoNetworkStream *fileStream;
//@property (nonatomic, retain, readonly) VideoFileStream *fileStream;
@property (nonatomic, assign) id<VideoH264DecoderDelegate> videoDelegate;

-(id) init;
-(BOOL) initDecoder;
-(BOOL) open:(NSString *) path;
-(BOOL) startDecode;
-(void) stopDecode;
-(void) clear;

@end

#endif /* VideoH264Decoder_h */
