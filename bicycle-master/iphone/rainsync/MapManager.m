//
//  MapManager.m
//  rainsync
//
//  Created by xorox64 on 12. 11. 19..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "MapManager.h"

@implementation MapManager

- (id)init{
    [super init];
    
   
    users = [[NSMutableArray alloc] init];
    route_lines = [[NSMutableArray alloc]init];

    return self;
    
}
- (NSInteger) getUserNum:(NSInteger)userid
{
    //@synchronized(self){
    for(int i=0; i<[users count]; ++i){
        NSInteger name= [[users objectAtIndex:i] intValue];
        if(name==userid)
            return i;
    }
    
    return -1;
    //}
    
}

- (NSInteger) createUser:(NSInteger)userid
{
    //@synchronized(self){
    [users addObject:[NSNumber numberWithInt:userid]];
    [route_lines addObject:[NSNull null]];
    //[route_views addObject:[NSNull null]];
    
    int i=[users count]-1;
    return i;
    //}
}

- (void) addPoint:(int)pos withLocation:(CLLocation *)newLocation
{
    

    CrumbPath *prev_line = [route_lines objectAtIndex:pos];
    if(prev_line == [NSNull null])
    {
        prev_line = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
        [route_lines replaceObjectAtIndex:pos withObject:prev_line];
        //[route_views replaceObjectAtIndex:pos withObject:[[CrumbPathView alloc] initWithOverlay:prev_line]];
        NSDictionary * dic = [[NSMutableDictionary alloc] initWithObjects:@[prev_line] forKeys:@[@"line"]];
        //[dic setObject:prev_line forKey:@"line"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newOverlay" object:nil userInfo:dic];
        NSLog(@"changed..");

        
    }else{
        

        MKMapRect updateRect = [prev_line addCoordinate:newLocation.coordinate];
        //NSLog(@"%lf %lf %lf %lf %p %p gg", updateRect.origin.x, updateRect.origin.y, updateRect.size.height,updateRect.size.width, route_views[pos], [NSNull null]);
        
        if (!MKMapRectIsNull(updateRect))
        {
            
            NSDictionary * dic = [[NSMutableDictionary alloc] initWithObjects:@[[NSValue valueWithPointer:&updateRect]] forKeys:@[@"rect"]];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"newRect" object:nil userInfo:dic];


        }
        
    }


    
    
}

//- (CrumbPathView *) getView:(CrumbPath *)path
//{
//    for (int i=0; i!=[route_lines count]; i++) {
//        if([route_lines objectAtIndex:i]==path)
//            return [route_views objectAtIndex:i];
//    }
//    return nil;
//}


- (void) clear
{
    for(int i=0; i<[users count]; ++i){
        [users removeObjectAtIndex:i];
        [route_views removeObjectAtIndex:i];
        [route_lines removeObjectAtIndex:i];
    }

}

@end
