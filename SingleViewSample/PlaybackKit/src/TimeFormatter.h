//
//  TimeFormatter.h
//  SingleViewSample
//
//  Created by hudapeng on 12/7/15.
//  Copyright © 2015 Baidu. All rights reserved.
//

@import Foundation;

@interface TimeFormatter : NSObject
+ (NSString*)convertSecond2HHMMSS:(NSTimeInterval)second;
@end
