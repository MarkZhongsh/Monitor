//
//  RTPDcode.m
//  Monitor
//
//  Created by suihong on 16/10/28.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTPUtil.h"

#define RTPHEADER_SIZE 72

@implementation RTPUtil

#pragma mark - RTP

+(struct RTPHeader *) HeaderDecode:(void *) data length:(int) length
{
//    if (*length < RTPHEADER_SIZE) {
//        *length = 0;
//        return NULL;
//    }
    if(data == NULL || length <= 0)
    {
        return NULL;
    }
    
    void *tmp = data;
    
    struct RTPHeader *header = (struct RTPHeader *) malloc(sizeof(struct RTPHeader));
    memset(header, 0, sizeof(struct RTPHeader));
    
    memcpy(&header->detail, tmp, 4);
    tmp+=4;
    NSLog(@"detail start --------------------------------");
    NSLog(@"detail version: %d", header->detail.version);
    NSLog(@"detail p: %d", header->detail.padding);
    NSLog(@"detail x: %d", header->detail.extension);
    NSLog(@"detail csrc: %d", header->detail.csrcLen);
    NSLog(@"detail m: %d", header->detail.marker);
    NSLog(@"detail payload: %d", header->detail.payload);
    NSLog(@"detail sequence number: %d", header->detail.sn);
    NSLog(@"detail end ----------------------------------");
    
    memcpy(&header->timestamp, tmp, 4);
    tmp+=4;
    NSLog(@"timestamp: %d", (unsigned int)header->timestamp);
    
    memcpy(&header->ssrc, tmp, 4);
    tmp+=4;
    NSLog(@"ssrc: %d", (int)header->ssrc);
    
    memcpy(&header->csrc, tmp, header->detail.csrcLen);
    tmp += header->detail.csrcLen;
    
//    length -= (tmp-data);
    
//    //添加start code
//    const UInt8 KStartCode[4] = {0, 0, 0, 1};
//    header->nalu = malloc(length+4);
//    header->naluLen = length+4;
//    memmove(header->nalu, KStartCode, sizeof(UInt8)*4);
//    memmove(header->nalu+sizeof(UInt8)*4, tmp, length);
    
    return header;
}

+(void) HeaderEncode:(void *) data length:(int) length
{
    
}

#pragma mark - fragment unit
+(bool) FUIndicatorEncode:(void *)data length:(int)len indicator:(struct FU_Indicator *)indicator
{
    return false;
}

+(bool) FUIndicatorDecode:(void *) data length:(int) len indicator:(struct FU_Indicator *)indicator
{
    if (indicator == NULL || len < 1)
        return false;
    
    memset(indicator, 0, sizeof(struct FU_Indicator));
    memcpy(indicator, data, 1);
    
    
    NSLog(@"indicator start -------------------------");
    NSLog(@"indicator type: %d", indicator->type);
    NSLog(@"indicator F: %d", indicator->F);
    NSLog(@"indicator NRI: %d", indicator->NRI);
    NSLog(@"indicator end ---------------------------");
    
    return true;
}

+(bool) FUHeaderEncode:(void *)data length:(int)len header:(struct FU_Header *)header
{
    return false;
}

+(bool) FUHeaderDecode:(void *)data length:(int)len header:(struct FU_Header *)header
{
    if(header == NULL || len < 1)
        return false;
    
    memset(header, 0, sizeof(struct FU_Header));
    memcpy(header, data, 1);
    
    NSLog(@"fu header start --------------------------");
    NSLog(@"header type: %d", header->type);
    NSLog(@"header start: %d", header->start);
    NSLog(@"header end: %d", header->end);
    NSLog(@"header R: %d", header->retain);
    NSLog(@"fu header end -----------------------------");
    
    return true;
}

#pragma mark - PayLoad

+(void) PayLoadDecode:(void *) data length:(int) length
{
    
}

+(void) PayLoadEncode:(void *) data length:(int) length
{
    
}


@end
