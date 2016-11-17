//
//  LogUtil.m
//  Monitor
//
//  Created by suihong on 16/11/17.
//  Copyright © 2016年 suihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogUtil.h"

@implementation LogUtil

+(void) PrintLog:(NSString *)format, ...
{
#ifdef MONITOR_DEBUG
    va_list paramList;
    va_start(paramList, format);
    NSString *log = [[NSString alloc] initWithFormat:format arguments:paramList];
    
    NSLog(@"log: %@", log);
    log = nil;
#endif
}

@end
