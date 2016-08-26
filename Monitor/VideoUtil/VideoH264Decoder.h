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

@interface VideoH264DecoderPacket : NSObject

@end

@protocol VideoH264DecoderDelegate <NSObject>

-(void) videoDecodeCallback:(CVPixelBufferRef) pixelBuff;

@end

@interface VideoH264Decoder : NSObject

@property (nonatomic, retain, readonly) VideoStream *fileStream;
@property (nonatomic, assign) id<VideoH264DecoderDelegate> videoDelegate;
@property (nonatomic, assign, readonly) BOOL readyToDecode;

-(id) init;
-(BOOL) initDecoder;
-(BOOL) open:(NSString *) path;
-(BOOL) startDecode;
-(void) stopDecode;


@end

#endif /* VideoH264Decoder_h */
