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
#define SOCKETERRORDOMAIN @"com.personal.socket"

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

    //udp打洞
    NSError *error;
    BOOL result = [self natSessionSave:addr port:port error:&error];
    if(!result)
    {
        NSLog(@"error msg: %@", [error localizedDescription]);
        return NO;
    }
    
    struct hostent *host = gethostbyname([addr UTF8String]);
    if(host == NULL || host->h_length <= 0)
    {
//        *error = [NSError errorWithDomain:SOCKETERRORDOMAIN code:NoHost userInfo:@{NSLocalizedDescriptionKey:@"can't find host"}];
        return NO;
    }
    struct sockaddr_in srvSock;
    memset(&srvSock, 0, sizeof(srvSock));
    srvSock.sin_len = sizeof(srvSock);
    srvSock.sin_family = AF_INET;
    srvSock.sin_port = htons(port);
    inet_pton(AF_INET, inet_ntoa(*((struct in_addr*)host->h_addr_list[0])), &srvSock.sin_addr);
    
    int res = connect(socketfd, (struct sockaddr *)&srvSock, sizeof(srvSock));
    if(res != 0)
    {
        NSLog(@"%s", strerror(errno));
        return NO;
    }
    
    return YES;
}

-(BOOL) natSessionSave:(NSString *) addr port:(int) port error:(NSError **) error
{
    
    if(socketfd <= 0)
    {
        *error = [NSError errorWithDomain:SOCKETERRORDOMAIN code:SocketNotInit userInfo:@{NSLocalizedDescriptionKey:@"socket is not init"}];
        return NO;
    }
    
    struct hostent *host = gethostbyname([addr UTF8String]);
    if(host == NULL || host->h_length <= 0)
    {
        *error = [NSError errorWithDomain:SOCKETERRORDOMAIN code:NoHost userInfo:@{NSLocalizedDescriptionKey:@"can't find host"}];
        return NO;
    }
    
    struct sockaddr_in natAddr;
    memset(&natAddr, 0, sizeof(natAddr));
    natAddr.sin_len = sizeof(natAddr);
    natAddr.sin_family = AF_INET;
    natAddr.sin_port = htons(port);
    inet_pton(AF_INET, inet_ntoa(*((struct in_addr*)host->h_addr_list[0])), &natAddr.sin_addr);
    socklen_t len = sizeof(natAddr);
    
    uint8_t natMsg[7] = "natMsg";
    long num = sendto(socketfd, natMsg, strlen((char*)natMsg)+1, 0, (struct sockaddr*)&natAddr, len);
    //sendto(socketfd, "test", 5, 0, (struct sockaddr*)&addr4, len);
    if(num <= 0)
    {
        *error = [NSError errorWithDomain:SOCKETERRORDOMAIN code:NATSessionNotSave userInfo:@{NSLocalizedDescriptionKey:@"can't not NAT save"}];
        return NO;
    }
    
    char buff[7] = "";
    socklen_t natAddrLen = sizeof(natAddr);
    num = recvfrom(socketfd, buff, 7, 0, (struct sockaddr*) &natAddr, &natAddrLen);
    if(num <= 0)
    {
        *error = [NSError errorWithDomain:SOCKETERRORDOMAIN code:NATSessionNotSave userInfo:@{NSLocalizedDescriptionKey:@"can't not NAT save"}];
        return NO;
    }
    NSLog(@"recv msg: %s", buff);
    *error = nil;
    
    return YES;
}

-(NSInteger) readData:(UInt32 *)data maxLength:(UInt32)length
{
    
    int retryTime = 0;
    NSInteger readNum = 0;
    
    //超时重试3次
//    while(retryTime < 3)
    while(true)
    {
        fd_set readSet;
        fd_set errSet;
        __DARWIN_FD_ZERO(&readSet);
        __DARWIN_FD_ZERO(&errSet);
        __DARWIN_FD_SET(socketfd, &readSet);
        
        struct timeval time;
        time.tv_usec = 2;
        time.tv_sec = 2;
        
        int ret = select(socketfd+1, &readSet, NULL, &errSet, &time);
        if( ret == 0) //timeout
        {
            retryTime ++;
            continue;
        }
        if( ret < 0)
        {
            NSLog(@"select error: %s", strerror(errno));
            break;
        }
        if(__DARWIN_FD_ISSET(socketfd, &errSet))
        {
            NSLog(@"select error: %s", strerror(errno));
            retryTime++;
            continue;
        }
        if(__DARWIN_FD_ISSET(socketfd, &readSet))
        {
            readNum = recv(socketfd, data, length, 0);
            break;
        }
    }
    
    return readNum;
}

-(NSData *) recvData
{
    
    fd_set readSet;
    __DARWIN_FD_ZERO(&readSet);
    __DARWIN_FD_SET(socketfd, &readSet);
    
    struct timeval time;
    time.tv_sec = 2;
    time.tv_usec = 2;
    int ret = select(socketfd+1, &readSet, NULL, NULL, &time);
    if(ret == -1)
    {
        NSLog(@"select error: %s", strerror(errno));
        return nil;
    }

    char buff[2048] = "";
    NSData *data = nil;
    if(__DARWIN_FD_ISSET(socketfd, &readSet))
    {
        long readBytes = recv(socketfd, buff, 2048, 0);
        data = [NSData dataWithBytes:buff length:readBytes];
        NSLog(@"read byte: %ld", readBytes);
    }
    else
    {
        NSLog(@"time out");
    }
    
    return data;
}

-(long) sendData:(NSData *) data
{
    fd_set writeSet;
    __DARWIN_FD_ZERO(&writeSet);
    __DARWIN_FD_SET(socketfd, &writeSet);
    
    struct timeval time;
    time.tv_sec = 2;
    time.tv_usec = 0;
    
    int res = select(socketfd+1, NULL, &writeSet, NULL, &time);
    if(res == -1)
    {
        NSLog(@"select error :%s", strerror(errno));
        return 0;
    }
    
    long sendNum = 0;
    if(__DARWIN_FD_ISSET(socketfd, &writeSet))
    {
        sendNum = send(socketfd, [data bytes], [data length], 0);
        if(sendNum < 0)
            NSLog(@"send error: %s", strerror(errno));
    }
    else
    {
        NSLog(@"timeout");
    }
    
    
    return 0;
}



-(void) disConnect
{
    if(socketfd == 0)
        return ;
    
    close(socketfd);
    socketfd = 0;
    
}

-(void) dealloc
{
    
}



@end










