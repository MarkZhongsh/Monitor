//
//  Socket.m
//  Monitor
//
//  Created by suihong on 16/9/9.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <netdb.h>

#import "Socket.h"

#define CFSAFE_RELEASE(x) { if((x)) { CFRelease(x); (x) = NULL; } }

static void SocketCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    CFSocketContext *context = (CFSocketContext *) info;
    if(context == NULL || context->info == NULL)
        return ;
    
    Socket *socket = (__bridge Socket*) context->info;
    if (socket.delegate == nil)
        return ;
    
    switch (type) {
        case kCFSocketReadCallBack:
            [socket.delegate readCallback];
            break;
        case kCFSocketWriteCallBack:
            [socket.delegate writeCallback];
        case kCFSocketConnectCallBack:
            [socket.delegate connectCallback];
        default:
            NSLog(@"socket error: %lu", type);
            break;
    }
}

@interface Socket ()
{
    CFSocketRef _socket;
    int socketfd;
}


@end

@implementation Socket

-(instancetype) init
{
    
    self = [super init];
    if(self)
    {
        socketfd = 0;
    }
    return self;
}

-(void) setUpSocketType:(SocketType)socketType
{
    if(socketfd == 0)
    {
        socketfd = socket(AF_INET, socketType, 0);
    }
}

-(BOOL) connectToAddress:(NSString *)addr port:(int)port
{
    if(socketfd < 0)
        return NO;
    
    struct sockaddr_in addr4;
    
    struct hostent *host = gethostbyname([addr UTF8String]);
    if(host->h_length <= 0)
    {
        NSLog(@"cant not get IP from the url: %@",addr );
        return NO;
    }
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = htons(port);
    inet_pton(AF_INET, inet_ntoa(*((struct in_addr*)host->h_addr_list[0])), &addr4.sin_addr);
    socklen_t len = sizeof(addr4);
    
    //udp打洞
    char *digHoleText = "hole";
    ssize_t sendNum = sendto(socketfd, (void*)digHoleText, 5, 0, (struct sockaddr*)&addr4, len);
    if(sendNum < 0)
    {
        NSLog(@"send error: %s", strerror(errno));
        return NO;
    }
    
    uint8_t data[31] = "";
    long recvNum = 0;
    while((recvNum = recvfrom(socketfd, data, 30, 0, (struct sockaddr*)&addr4, &len) != 0))
    {
        NSLog(@"recvNum: %ld", recvNum);
        NSLog(@"len: %u", len);
        NSLog(@"data: %s", data);
    }
    return YES;
}

-(BOOL) natSessionSave:(NSString *) addr port:(int) port error:(NSError *) error
{
    if(socketfd <= 0)
        return NO;
    
    struct hostent *host = gethostbyname([addr UTF8String]);
    if(host == NULL || host->h_length <= 0)
        return NO;
    
    struct sockaddr_in natAddr;
    memset(&natAddr, 0, sizeof(natAddr));
    natAddr.sin_family = AF_INET;
    natAddr.sin_port = htons(port);
    natAddr.sin_len = sizeof(natAddr);
    inet_pton(socketfd, inet_ntoa(*((struct in_addr*)host->h_addr_list[0])), &natAddr.sin_addr);
    
    const char *natMsg = "natMsg";
    long num = sendto(socketfd, natMsg, strlen(natMsg)+1, 0, (struct sockaddr*)&natAddr, sizeof(natAddr));
    if(num <= 0)
    {
        return NO;
    }
    
    char buff[7] = "";
    socklen_t natAddrLen = sizeof(natAddr);
    num = recvfrom(socketfd, buff, 7, 0, (struct sockaddr*) &natAddr, &natAddrLen);
    if(num <= 0)
    {
        return NO;
    }
    
    return YES;
}

-(BOOL) disConnect
{
    if(_socket == NULL)
        return NO;
    
    if(CFSocketIsValid(_socket))
        CFSocketInvalidate(_socket);
    
    return YES;
}

-(long) readData:(UInt32 *)data maxLength:(UInt32)length
{
    ssize_t readLen = recv(CFSocketGetNative(_socket), data, length, MSG_DONTWAIT);
    return readLen;
}

-(long) read:(UInt32*) data length:(UInt32) length
{
    if(_socket == NULL || CFSocketIsValid(_socket) == NO)
        return 0;
    
    
    
    return 0;
}

-(long) writeData:(UInt32 *)data length:(UInt32)length
{
    if(_socket == NULL || CFSocketIsValid(_socket) == NO)
        return 0;
    
    return 0;
}

-(void) dealloc
{
    if(CFSocketIsValid(_socket))
        CFSocketInvalidate(_socket);
    CFSAFE_RELEASE(_socket);
}



@end










