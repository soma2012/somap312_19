//
//  Utility.m
//  rainsync
//
//  Created by xorox64 on 12. 11. 12..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+ (float)calculateCalorie:(float)avgSpd {
    float kcalConstant = 0.0f;
    if (avgSpd <=1){
        kcalConstant = 0;
    }
    else if (avgSpd <= 13) {
        kcalConstant = 0.065f;
    }
    else if (avgSpd <= 16) {
        kcalConstant = 0.0783f;
    }
    else if (avgSpd <= 19) {
        kcalConstant = 0.0939f;
    }
    else if (avgSpd <= 22) {
        kcalConstant = 0.113f;
    }
    else if (avgSpd <= 24) {
        kcalConstant = 0.124f;
    }
    else if (avgSpd <= 26) {
        kcalConstant = 0.136f;
    }
    else if (avgSpd <= 27) {
        kcalConstant = 0.149f;
    }
    else if (avgSpd <= 29) {
        kcalConstant = 0.163f;
    }
    else if (avgSpd <= 31) {
        kcalConstant = 0.179f;
    }
    else if (avgSpd <= 32) {
        kcalConstant = 0.196f;
    }
    else if (avgSpd <= 34) {
        kcalConstant = 0.215f;
    }
    else if (avgSpd <= 37) {
        kcalConstant = 0.259f;
    }
    else {  // avgSpeed 40km/h 이상
        kcalConstant = 0.311f;
    }
    
    return kcalConstant;
}

+(NSString*)getStringTime:(double)time
{
    int i_time = (int)time;
    int sec = i_time%60;
    int min = i_time/60%60;
    int hour = i_time/60/60%24;
    
    
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
    
}

+(int)getTimeSecond:(double)time {
    return (int)time%60;
}
+(int)getTimeMinute:(double)time {   
    return (int)time/60%60;
}
+(int)getTimeHour:(double)time {
    return (int)time/60/60%24;
}

+(NSString*)timeToDate:(double)time
{
    
    NSDate *date=[[NSDate alloc] initWithTimeIntervalSince1970:time];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale =[[NSLocale alloc] initWithLocaleIdentifier:@"ko_KR"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString* result=[dateFormatter stringFromDate:date];
    [date release];
    [locale release];
    [dateFormatter release];
    return result;
}

+(double)metreTokilometre:(double)metre
{
    return metre/1000.0;
    
}

+(double)mpsTokph:(double)mps{
    return mps*3.6;
}

+(UIImage*)numberImagify:(NSString*)number
{
    static NSMutableArray *font=nil;
    
    if(font==nil){
        font = [[NSMutableArray alloc] init];
        for (int i=0; i<10; i++) {
            font[i]=[UIImage imageNamed:[NSString stringWithFormat:@"%d.png",i]];
        }
        
        font[10]=[UIImage imageNamed:@"dot.png"];
        font[11]=[UIImage imageNamed:@"_.png"];
        
        //[font addObject:[UIImage imageNamed:@"dot.png"]];
    }
    
    CGFloat width=0;
    
    for(int i=0; i<[number length]; ++i)
    {
        char ch=[number characterAtIndex:i];
        if(ch>='0' && ch<='9')
        {
            width+=((UIImage*)font[ch-'0']).size.width;
        }else if(ch=='.'){
            width+=((UIImage*)font[10]).size.width;
        }else if(ch==':'){
            width+=((UIImage*)font[11]).size.width;
        }
    }
    
    
    UIGraphicsBeginImageContext(CGSizeMake(width, ((UIImage*)font[0]).size.height));
    width=0;
    for(int i=0; i<[number length]; ++i)
    {
        char ch=[number characterAtIndex:i];
        UIImage *buf;
        if(ch>='0' && ch<='9')
        {
            buf=font[ch-'0'];
            [buf drawInRect:CGRectMake(width, 0, buf.size.width, buf.size.height)];
            width+=buf.size.width;
        }else if(ch=='.'){
            buf=[font objectAtIndex:10];
            [buf drawInRect:CGRectMake(width, 0, buf.size.width, buf.size.height)];
            width+=buf.size.width;
        }else if(ch==':'){
            buf=[font objectAtIndex:11];
            [buf drawInRect:CGRectMake(width, 0, buf.size.width, buf.size.height)];
            width+=buf.size.width;
        }
    }
   
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}


@end
