//
//  Socket.h
//  Monitor
//
//  Created by suihong on 16/9/9.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef Socket_h
#define Socket_h

#import <sys/socket.h>

typedef enum
{
    SocketTcp = SOCK_STREAM, SocketUdp = SOCK_DGRAM
} SocketType;

typedef enum
{
  SocketNotInit = -1000, NoHost, NATSessionNotSave,
} SocketErrorCode;

@protocol SocketDelegate <NSObject>

-(void) readCallback;

-(void) writeCallback;

-(void) connectCallback;

@end

@interface Socket : NSObject

@property (nonatomic, weak) id<SocketDelegate> delegate;

-(instancetype) init;

-(void) setUpSocketType:(SocketType) type;

-(BOOL) connectToAddress:(NSString*) addr port:(int) port;

-(void) disConnect;

-(NSInteger) readData:(UInt32*) data maxLength:(UInt32) length;

-(long) writeData:(UInt32*) data length:(UInt32) length;

@end

#endif /* Socket_h */
