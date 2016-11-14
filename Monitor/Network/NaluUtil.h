//
//  NaluUtil.h
//  Monitor
//
//  Created by suihong on 16/11/11.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef NaluUtil_h
#define NaluUtil_h

//const uint8_t KStartCode[4] = { 0, 0, 0, 1};
//const uint8_t KStartCodeLen = sizeof(KStartCode)/sizeof(KStartCode[0]);

@interface NaluUtil: NSObject

struct Nalu
{
    char data[2048];
    UInt32 len;
};

@property (nonatomic, assign, readonly) int a;

+(bool) addStartCode:(void *) data size:(int) size nalu:(struct Nalu *) nalu;

@end

#endif /* NaluUtil_h */
