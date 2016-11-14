//
//  Nalu.m
//  Monitor
//
//  Created by suihong on 16/11/11.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NaluUtil.h"

const uint8_t KStartCode[4] = { 0, 0, 0, 1};
const uint8_t KStartCodeLen = sizeof(KStartCode)/sizeof(KStartCode[0]);

@implementation NaluUtil

+(bool) addStartCode:(void *)data size:(int)size nalu:(struct Nalu *)nalu
{
    
    if(nalu == NULL || data == NULL || size < 0)
        return false;
    
    memset(nalu, 0, sizeof(struct Nalu));
    memcpy(nalu->data, KStartCode, KStartCodeLen);
    memcpy(nalu->data+KStartCodeLen, data, size);
    
    nalu->len = size+KStartCodeLen;
    
    return true;
}

@end
