//
//  DetailViewController.h
//  rainsync
//
//  Created by 승원 김 on 12. 11. 6..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Utility.h"
#import "RidingDB.h"


@interface DetailViewController : UIViewController <MKMapViewDelegate>
{
    MKPolyline *routeLine;
    MKPolylineView *view;
    NSMutableDictionary *rawdata;
    UITableViewCell *_mapCell;
}
@property (retain, nonatomic) IBOutlet UITableView *detailTableView;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSString *rectime;
@property (strong, nonatomic) NSString *dist;
@property (strong, nonatomic) NSString *altit;
@property (strong, nonatomic) NSString *avgs;
@property (strong, nonatomic) NSString *calo;

// cell generators
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithRawData:(NSMutableDictionary *)data;
- (UITableViewCell *)blankCell;
- (UITableViewCell *)cellForLocationIndex:(NSInteger)index; // 8
- (UITableViewCell *)cellForMapView;

@end
