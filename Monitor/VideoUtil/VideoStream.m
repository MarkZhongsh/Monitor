//
//  VideoStream.m
//  Monitor
//
//  Created by suihong on 16/8/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VideoStream.h"

@interface VideoStream ()

@property uint8_t *buffer;
@property NSInteger bufSize;
@property NSInteger bufferCap;

@end

@implementation VideoStream

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.bufSize = 0;
        self.bufferCap = 1024 * 512;
        self.buffer = malloc(self.bufferCap);
    }
    
    return self;
}

-(BOOL) open:(NSString *)path
{
    return NO;
}

-(void) dealloc
{
    free(self.buffer);
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

-(int) getStream:(void*) dest size:(int) size
{
    
    if (self.fileStream == nil) {
        return 0;
    }

    if(self.bufSize < self.bufferCap && [self.fileStream hasBytesAvailable])
    {
        NSInteger readBytes = [self.fileStream read:self.buffer+self.bufSize maxLength:self.bufferCap-self.bufSize];
        self.bufSize += readBytes;
    }
    
    if (self.bufSize < size) {
        size = (int)self.bufSize;
    }
    
    //内存内容复制
    memcpy(dest, self.buffer, size);
    
    //内存移位
    memmove(self.buffer, self.buffer+(size), self.bufSize-size);
    self.bufSize -= size;
    
    return size;
}

-(void) dealloc
{
    [self.fileStream close];
    free(self.buffer);
    
    self.buffer = NULL;
}






@end


















