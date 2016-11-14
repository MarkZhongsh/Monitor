//
//  RTPDecode.h
//  Monitor
//
//  Created by suihong on 16/10/28.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef RTPDecode_h
#define RTPDecode_h

//@interface RTPHeader : NSObject
//
//@property (nonatomic, assign) UInt8 v;
//@property (nonatomic, assign) UInt8 p;
//@property (nonatomic, assign) UInt8 x;
//@property (nonatomic, assign) UInt8 cc;
//@property (nonatomic, assign) UInt8 m;
//@property (nonatomic, assign) UInt8 pt;
//@property (nonatomic, assign) UInt16 sequenceNumber;
//@property (nonatomic, assign) UInt32 timestamp;
//@property (nonatomic, assign) UInt32 ssrc;
//@property (nonatomic, assign) UInt32 csrc[15];
//@property (nonatomic, assign) UInt8 csrcLen;
//
//@end

//RTP 前32位内容 - Littile Endian
typedef struct {
    UInt8 csrcLen:4;    //CSRC计数器
    UInt8 extension:1;  //扩展位
    UInt8 padding:1;    //填充位
    UInt8 version:2;    //版本号
    
    UInt8 payload:7;    //载荷类型
    UInt8 marker:1;     //标记位
    
    UInt16 sn;
} Detail;

struct RTPHeader {
//    UInt8 v;                //版本号
//    UInt8 p;                //填充位
//    UInt8 x;                //扩展位
//    UInt8 cc;               //CSRC计数器
//    UInt8 m;                //标记位
//    UInt8 pt;               //载荷类型
//    UInt16 sequenceNumber;  //序列号
    Detail detail;          //RTP Header 前32位数据
    UInt32 timestamp;       //时间戳
    UInt32 ssrc;            //同步源标识符
    UInt32 csrc[15];        //贡献源列表(0 - 15)
//    void *nalu;             //nalu内容
//    UInt32 naluLen;         //nalu长度
};

struct FU_Indicator {
    
    u_char type:5;
    u_char NRI:2;
    u_char F:1;
};

struct FU_Header {
    u_char type:5;      //类型
    u_char retain:1;    //保留位, 一般为0
    u_char end:1;       //结束位, 当结束位为1时开始位不能为0
    u_char start:1;     //开始位, 当开始位为1时结束位不能为0
};

@interface RTPPayLoadType : NSObject

@end


@interface RTPUtil : NSObject

+(struct RTPHeader *) HeaderDecode:(void *) data length:(int) length;

+(void) HeaderEncode:(void *) data length:(int) length;

+(bool) FUIndicatorDecode:(void *) data length:(int) len indicator:(struct FU_Indicator *) indicator;

+(bool) FUIndicatorEncode:(void *) data length:(int) len indicator:(struct FU_Indicator *) indicator;

+(bool) FUHeaderEncode:(void *) data length:(int) len header:(struct FU_Header *) header;

+(bool) FUHeaderDecode:(void *) data length:(int) len header:(struct FU_Header *) header;

+(void) PayLoadDecode:(void *) data length:(int) length;

+(void) PayLoadEncode:(void *) data length:(int) length;

@end


#endif /* RTPDecode_h */
