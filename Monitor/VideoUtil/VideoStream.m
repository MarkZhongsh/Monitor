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





























