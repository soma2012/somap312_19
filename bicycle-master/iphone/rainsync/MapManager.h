//
//  MapManager.h
//

//
//  Created by xorox64 on 12. 11. 19..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import <MapKit/MapKit.h>

@interface MapManager : NSObject <MKMapViewDelegate>
{
    NSMutableArray *users;
    NSMutableArray *route_lines;
    NSMutableArray *route_views;


}
@property (nonatomic, retain) MKMapView *mapView;
- (NSInteger) getUserNum:(NSInteger)userid;
- (NSInteger) createUser:(NSInteger)userid;
- (void) addPoint:(int)pos withLocation:(CLLocation *)newLocation;
- (void) clear;

@end
