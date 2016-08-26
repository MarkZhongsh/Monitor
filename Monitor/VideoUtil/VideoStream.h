//
//  VideoStream.h
//  Monitor
//
//  Created by suihong on 16/8/18.
//  Copyright © 2016年 suihong. All rights reserved.
//

#ifndef VideoStream_h
#define VideoStream_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface VideoStream : NSObject

-(id) init;

- (NSUInteger) getStream:(void*) dest size:(NSUInteger) size;

- (BOOL) open:(NSString*) path;

@end

@interface VideoFileStream : VideoStream

-(id) init;


@end

@interface VideoNetworkStream : VideoStream

@end


#endif /* VideoStream_h */
