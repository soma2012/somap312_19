//
//  DetailViewController.m
//  rainsync
//
//  Created by 승원 김 on 12. 11. 6..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorWithHex.h"

#define getNibName(nibName) [NSString stringWithFormat:@"%@%@", nibName, ([UIScreen mainScreen].bounds.size.height == 568)? @"-568":@""]

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withID:(int)index
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        view = [NSNull null];
        
        RidingDB *ridingdb =[[RidingDB alloc] init];
        rawdata = [ridingdb loadRiding:index];
        [ridingdb release];
        
        // Custom initialization      
//        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    return self;
}




- (void)setRoute:(NSMutableArray *)locations
{
    if([locations count]==0)
        return;
    
    int i=0;
    double minX=INFINITY,minY=INFINITY,maxX=-INFINITY,maxY=-INFINITY;
    
    for (CLLocation *location in locations) {
        
        if(minX>location.coordinate.latitude)
            minX=location.coordinate.latitude;
        
        if(minY>location.coordinate.longitude)
            minY=location.coordinate.longitude;
        
        if(maxX<location.coordinate.latitude)
            maxX=location.coordinate.latitude;
        
        if(maxY<location.coordinate.longitude)
            maxY=location.coordinate.longitude;

        i++;
        
        
    }


    NSLog(@"%lf %lf %lf %lf", minX, maxX, minY,maxY);
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta=(maxX-minX);
    span.longitudeDelta=(maxY-minY);
    region.span=span;

    region.center=CLLocationCoordinate2DMake((maxX+minX)/2, (maxY+minY)/2);
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIView* bview = [[UIView alloc] init];
    bview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:getNibName(@"background")]];
    [_detailTableView setBackgroundView:bview];
    [bview release];
    self.detailTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.detailTableView.separatorColor = [UIColor colorWithHexString:@"0x333333"];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_mapView release];
    [_detailTableView release];
    [rawdata release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMapView:nil];
    [self setDetailTableView:nil];
    [super viewDidUnload];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	
    if(overlay == routeLine){
        if(view == [NSNull null])
        {
            view = [[MKPolylineView alloc] initWithPolyline:routeLine];
            view.fillColor = [UIColor redColor];
            view.strokeColor = [UIColor redColor];
            view.lineWidth = 3;
        }
        overlayView = view;
    }

    return overlayView;
    
}

#pragma mark -
#pragma mark Tableview Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *counts;
    counts = [NSArray arrayWithObjects:
              [NSNumber numberWithInt:1],  //map
              [NSNumber numberWithInt:7],  //location
              nil];
    
    return [[counts objectAtIndex:section] integerValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *titles;
    titles = [NSArray arrayWithObjects:
              @"날짜",                                      //map
              @"기록",               //location
              nil];
    
    return [titles objectAtIndex:section];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [headerView setBackgroundColor:[UIColor clearColor]];
    

    if (section == 0) {
        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(5,0,300,44)];
        headerLabel.backgroundColor= [UIColor clearColor];
        headerLabel.text= [NSString stringWithFormat:@"%@", [Utility timeToDate:[[rawdata objectForKey:@"start_date"] doubleValue]]];
        headerLabel.font = [UIFont boldSystemFontOfSize:17];
        headerLabel.textColor = [UIColor whiteColor];
        [headerView addSubview: headerLabel];
        [headerLabel release];
    }
    else if (section == 1) {
        UILabel *recordLabel=[[UILabel alloc]initWithFrame:CGRectMake(5,0,300,44)];
        recordLabel.backgroundColor= [UIColor clearColor];
        recordLabel.text=@"상세 기록";
        recordLabel.font = [UIFont boldSystemFontOfSize:17];
        recordLabel.textColor = [UIColor whiteColor];
        [headerView addSubview: recordLabel];
        [recordLabel release];
    }
    else {
        [headerView setBackgroundColor:[UIColor clearColor]];
    }

    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    switch (section)
    {
        case 0: return [self cellForMapView];
        case 1: return [self cellForLocationIndex:indexPath.row];
    }
    
    return nil;
}

#pragma mark -
#pragma mark Tableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 240.0f;
    }
    return [_detailTableView rowHeight];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if its the map url cell, open the location in Google maps
    //
//    if (indexPath.section == 4) // map url is always last section
//    {
//        NSString *ll = [NSString stringWithFormat:@"%f,%f",
//                        self.placemark.location.coordinate.latitude,
//                        self.placemark.location.coordinate.longitude];
//        ll = [ll stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@",ll];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//        
//        [_detailTableView deselectRowAtIndexPath:indexPath animated:NO];
//    }
}

#pragma mark - cell generators

- (UITableViewCell *)blankCell
{
    NSString *cellID = @"Cell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)cellForLocationIndex:(NSInteger)index
{
    NSArray const *keys = [NSArray arrayWithObjects:
                           @"시작 시간",
                           @"종료 시간",
                           @"주행 시간",
                           @"주행 거리",
                           @"평균 속도",
                           @"최고 속도",
                           @"칼로리",
                           nil];
    
    if (index >= [keys count])
        index = [keys count] - 1;
    
    UITableViewCell *cell = [self blankCell];
    
    // setup
    NSString *key = [keys objectAtIndex:index];
    NSString *ivar = @"";

    
    // look up the values, special case lat and long and timestamp but first, special case placemark being nil.
    if ([key isEqualToString:@"시작 시간"]) {
//        ivar = _startDate;    //측정 시작 시간 표시
        ivar = [Utility timeToDate:[[rawdata objectForKey:@"start_date"] doubleValue]];
        
    }
    else if ([key isEqualToString:@"종료 시간"])
    {

        ivar = [Utility timeToDate:[[rawdata objectForKey:@"end_date"] doubleValue]];
       
        
    }
    else if ([key isEqualToString:@"주행 시간"])
    {
        
        ivar = [Utility getStringTime:[[rawdata objectForKey:@"time"] doubleValue] ];
    }
    else if ([key isEqualToString:@"주행 거리"])
    {
        double distance = [Utility metreTokilometre:[[rawdata objectForKey:@"distance"] doubleValue] ];
        ivar = [NSString stringWithFormat:@"%.1f km", distance];
    }
    else if ([key isEqualToString:@"평균 속도"])
    {
        double avgSpeed = [Utility mpsTokph:[[rawdata objectForKey:@"speed"] doubleValue] ];
        ivar = [NSString stringWithFormat:@"%.1f km/h", avgSpeed];
    }
    else if ([key isEqualToString:@"최고 속도"])
    {
        double maxSpeed = [Utility mpsTokph:[[rawdata objectForKey:@"max_speed"] doubleValue]];
        ivar = [NSString stringWithFormat:@"%.1f km/h", maxSpeed];
    }
    else if ([key isEqualToString:@"칼로리"])
    {
        double calorie = [[rawdata objectForKey:@"calorie"] doubleValue];
        ivar = [NSString stringWithFormat:@"%.1f kcal", calorie];
    }
//    else
//    {
//        double var = [self doubleForObject:self.placemark.location andSelector:NSSelectorFromString(key)];
//        ivar = [self displayStringForDouble:var];
//    }
    
    // set cell attributes
    cell.backgroundColor = [UIColor colorWithHexString:@"0x3f4547"];
    cell.textLabel.text = key;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = ivar;
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
    cell.detailTextLabel.textColor = [UIColor colorWithHex:0x3D89BF];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    return cell;
}

- (UITableViewCell *)cellForMapView
{
    if (_mapCell)
        return _mapCell;
    
    

    
    
    // if not cached, setup the map view...
    CGFloat cellWidth = self.view.bounds.size.width - 20;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        cellWidth = self.view.bounds.size.width - 90;
    }
    

//    MKCoordinateRegion region =  MKCoordinateRegionMakeWithDistance(self.placemark.location.coordinate, 200, 200);
//    [map setRegion:region];
    CGRect frame = CGRectMake(0, 0, cellWidth, 240);
    _mapView = [[MKMapView alloc] initWithFrame:frame];
    _mapView.delegate =self;
    
    _mapView.layer.masksToBounds = YES;
    _mapView.layer.cornerRadius = 10.0;
    _mapView.mapType = MKMapTypeStandard;
    //[_mapView setScrollEnabled:NO];
    
   
    
    
    NSMutableArray * locations = [rawdata objectForKey:@"locations"];
    CLLocationCoordinate2D * coords = malloc([locations count]*sizeof(CLLocationCoordinate2D));
    
    int i=0;
    CLLocationCoordinate2D point;
    CLLocationCoordinate2D mid;
    //CLLocationCoordinate2D northEastPoint;
    //CLLocationCoordinate2D southWestPoint;
    
    for (CLLocation *location in locations) {
        point = location.coordinate;
        if(i==0)
            mid=point;
        coords[i++] = point;
        //point = MKMapPointForCoordinate(location.coordinate);
        
        
        //coords[i++]= point;
        
        
    }
    
    routeLine = [MKPolyline polylineWithCoordinates:coords count:[locations count]];
    [self.mapView addOverlay:routeLine];
    //    //point.latitude /= [locations count];
    //    //point.longitude /= [locations count];
    [self setRoute:locations];
    //[self setMapCenter:mid];
    
    //MKMapRectMake(southWestPoint.x, southWestPoint.y, northEastPoint.x - southWestPoint.x, northEastPoint.y - southWestPoint.y);
    
    free(coords);

    
    
    // add a pin using self as the object implementing the MKAnnotation protocol
//    [map addAnnotation:self];
    
    NSString * cellID = @"Cell";
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
    
    [cell.contentView addSubview:_mapView];
//    [map release];
    
    _mapCell = [cell retain];
    return cell;
}

@end
