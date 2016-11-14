//
//  VideoStream.m
//  Monitor
//
//  Created by suihong on 16/8/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VideoStream.h"
#import "Socket.h"
#import "RTPUtil.h"
#import "NaluUtil.h"

//const uint8_t KStartCode[4] = { 0, 0, 0, 1};
//const uint8_t KStartCodeLen = sizeof(KStartCode)/sizeof(KStartCode[0]);


@interface VideoStream ()

@end

@implementation VideoStream

-(id) init
{
    self = [super init];
    
    return self;
}

-(BOOL) open:(NSString *)path
{
    return NO;
}

@end

@interface VideoFileStream()

@property NSInputStream *fileStream;

@end

@implementation VideoFileStream

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.fileStream = nil;
    }
    
    return self;
}



-(BOOL) open:(NSString *)path
{
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:path];
    
    if (self.fileStream == nil) {
        return NO;
    }
    
    [self.fileStream open];
    
    return YES;
}

-(void) close
{
    [self.fileStream close];
}

-(NSUInteger) getStream:(void*) dest size:(NSUInteger) size
{
    
    if (self.fileStream == nil || [self.fileStream hasBytesAvailable] == NO) {
        return 0;
    }
    
    size = [self.fileStream read:dest maxLength: size];
    return size;
}

-(void) dealloc
{
    [self.fileStream close];
}

@end



#pragma mark - Video Network Stream
@interface VideoNetworkStream () <SocketDelegate>
{
    Socket *udp;
}


@end

@implementation VideoNetworkStream

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        udp = [[Socket alloc] init];
        [udp setDelegate:self];
    }
    
    return self;
}

-(BOOL) openAddr:(NSString *)addr port:(int)port
{
    [udp setUpSocketType:SocketUdp];
    return [udp connectToAddress:addr port:port];
}

-(NSUInteger) getStream:(void *) dest size:(NSUInteger)size
{
    int mark = 1, end = 1; //标记位 结束位
    char buf[16384] = "";
    int bufIndex = 0;
    do
    {
        NSLog(@"deal with data start ------------------------------");
        
        char tmpBuf[1024] = "";
        int tmpSize = (int)[udp readData:(void*)tmpBuf maxLength:(UInt32) size];
        struct RTPHeader *rtpHdr = [RTPUtil HeaderDecode:tmpBuf length:tmpSize];
        mark = rtpHdr->detail.marker;
        
        if(mark == 1 && end == 1)
        {
            void *naluData = tmpBuf+12+rtpHdr->detail.csrcLen*4;
            int naluDataLen = tmpSize-12-rtpHdr->detail.csrcLen*4;
            struct Nalu nalu;
            memset(nalu.data, 0, sizeof(char)*2048);
            bool success = [NaluUtil addStartCode:naluData size:naluDataLen nalu:&nalu];
            if(success) {
                memcpy(buf, nalu.data, nalu.len);
                bufIndex = nalu.len;
            }
        }
        else {
            void * fuData = tmpBuf+12;
            int fuDataLen = tmpSize-14;
            struct FU_Indicator indicator;
            bool indSuc = [RTPUtil FUIndicatorDecode:fuData length:1 indicator:&indicator];
            struct FU_Header header;
            bool fhdrSuc = [RTPUtil FUHeaderDecode:fuData+1 length:1 header:&header];
            
            if(!indSuc || !fhdrSuc)
            {
                NSLog(@"get indicator or fu header error!");
                return 0;
            }
            
            end = header.end;
            memcpy(buf+bufIndex, fuData, fuDataLen);
            bufIndex += fuDataLen;
            
            // time to create nalu
            if(end == 1)
            {
                indicator.type = header.type;
                memmove(buf+1, buf, bufIndex);
                memcpy(buf, &indicator, sizeof(indicator));
                bufIndex += sizeof(indicator);
                
                struct Nalu nalu;
                memset(nalu.data, 0, sizeof(char)*2048);
                nalu.len = 0;
                bool success = [NaluUtil addStartCode:buf size:bufIndex nalu:&nalu];
                if(success) {
                    memcpy(buf, nalu.data, nalu.len);
                    bufIndex = nalu.len;
                }
            }
        }
        
        NSLog(@"deal with data end ----------------------");
    }while(mark == 0 && end == 0);
    
    memcpy(dest, buf, bufIndex);
    size = bufIndex;
    return size;
}

-(int) getNextNalu:(void *) data size:(int) size
{
    return 0;
}

-(void) close
{
    [udp disConnect];
    udp = nil;
}

#pragma mark - Socket Delegate
-(void) readCallback
{
    NSLog(@"read call back");
}

-(void) writeCallback
{
    NSLog(@"write call back");
}

-(void) connectCallback
{
    NSLog(@"connect call back");
}


-(void) dealloc
{
    udp = nil;
}

@end





























