//
//  TimeFormatter.m
//  SingleViewSample
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

#import "TimeFormatter.h"

@implementation TimeFormatter

+ (NSString *)convertSecond2HHMMSS:(NSTimeInterval)time {
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        lround(floor(time / 3600.)) % 100,
                        lround(floor(time / 60.)) % 60,
                        lround(floor(time)) % 60];
    
    NSString *extraZeroes = @"00:";
    
    if ([string hasPrefix:extraZeroes]) {
        string = [string substringFromIndex:extraZeroes.length];
    }
    
    return string;
}

@end
