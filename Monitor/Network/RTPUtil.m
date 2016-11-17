//
//  RTPDcode.m
//  Monitor
//
//  Created by suihong on 16/10/28.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTPUtil.h"
#import "LogUtil.h"

#define RTPHEADER_SIZE 12

@interface RTPUtil ()

@end

@implementation RTPUtil

#pragma mark - RTP

+(struct RTPHeader *) HeaderDecode:(void *) data length:(int) length
{
    if(data == NULL || length <= RTPHEADER_SIZE)
    {
        return NULL;
    }
    
    void *tmp = data;
    
    struct RTPHeader *header = (struct RTPHeader *) malloc(sizeof(struct RTPHeader));
    memset(header, 0, sizeof(struct RTPHeader));
    
    memcpy(&header->detail, tmp, 4);
    header->detail.sn = ntohs(header->detail.sn);
    tmp+=4;
    [LogUtil PrintLog:@"detail start --------------------------------"];
    [LogUtil PrintLog:@"detail version: %d %d", header->detail.version];
    [LogUtil PrintLog:@"detail padding: %d", header->detail.padding];
    [LogUtil PrintLog:@"detail extension: %d", header->detail.extension];
    [LogUtil PrintLog:@"detail csrc: %d", header->detail.csrcLen];
    [LogUtil PrintLog:@"detail mark: %d", header->detail.marker];
    [LogUtil PrintLog:@"detail payload: %d", header->detail.payload];
    [LogUtil PrintLog:@"detail sequence number: %d", header->detail.sn];
    [LogUtil PrintLog:@"detail payload: %d", header->detail.payload];
    [LogUtil PrintLog:@"detail end ----------------------------------"];
    
    memcpy(&header->timestamp, tmp, 4);
    tmp+=4;
    [LogUtil PrintLog:@"timestamp: %d", (unsigned int)header->timestamp];
    
    memcpy(&header->ssrc, tmp, 4);
    tmp+=4;
    [LogUtil PrintLog:@"ssrc: %d", (int)header->ssrc];
    
    memcpy(&header->csrc, tmp, header->detail.csrcLen);
//    tmp += header->detail.csrcLen;
    
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
    
    [LogUtil PrintLog:@"indicator start -------------------------"];
    [LogUtil PrintLog:@"indicator type: %d", indicator->type];
    [LogUtil PrintLog:@"indicator F: %d", indicator->F];
    [LogUtil PrintLog:@"indicator NRI: %d", indicator->NRI];
    [LogUtil PrintLog:@"indicator end -------------------------"];
    
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
    
    
    [LogUtil PrintLog:@"fu header start --------------------------"];
    [LogUtil PrintLog:@"header type: %d", header->type];
    [LogUtil PrintLog:@"header start: %d", header->start];
    [LogUtil PrintLog:@"header end: %d", header->end];
    [LogUtil PrintLog:@"header remain: %d", header->remain];
    [LogUtil PrintLog:@"fu header -------------------------"];
    
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
