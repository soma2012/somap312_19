//
//  Utility.h
//  rainsync
//
//  Created by xorox64 on 12. 11. 12..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+(NSString*)timeToDate:(double)time;
+ (float)calculateCalorie:(float)avgSpd;
+(NSString*)getStringTime:(double)time;
+(double)metreTokilometre:(double)metre;
+(double)mpsTokph:(double)mps;

+(int)getTimeSecond:(double)time;
+(int)getTimeMinute:(double)time;
+(int)getTimeHour:(double)time;
+(UIImage*)numberImagify:(NSString*)number;
@end
