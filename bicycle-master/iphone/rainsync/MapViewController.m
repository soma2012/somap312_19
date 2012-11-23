//
//  MapViewController.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "MapViewController.h"
#import "CrumbPathView.h"

@interface MapViewController ()

@end

@implementation MapViewController



- (void)newOverlay:(NSNotification *)noti
{
    
    id<MKOverlay> overlay=[[noti userInfo] objectForKey:@"line"];
    
    NSMutableArray *arr =[[NSMutableArray alloc] initWithArray:@[overlay, [NSNull null]]];
    [path addObject:arr];
    [self.mapView addOverlay:overlay];
}


- (void)newRect:(NSNotification *)noti
{
    
    MKMapRect *rect=[[[noti userInfo] objectForKey:@"rect"] pointerValue];
    // There is a non null update rect.
    // Compute the currently visible map zoom scale
    MKZoomScale currentZoomScale = (CGFloat)(_mapView.bounds.size.width / _mapView.visibleMapRect.size.width);
    // Find out the line width at this zoom scale and outset the updateRect by that amount
    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
    *rect = MKMapRectInset(*rect, -lineWidth, -lineWidth);
    // Ask the overlay view to update just the changed area.
    
    for (NSMutableArray *arr in path) {
        MKOverlayView *view=arr[1];
        if(view!=[NSNull null]){
        [view setNeedsDisplayInMapRect:(*rect)];
        }
        
    }
//    MKZoomScale currentZoomScale = (CGFloat)(_mapView.bounds.size.width / _mapView.visibleMapRect.size.width);
//    //            // Find out the line width at this zoom scale and outset the updateRect by that amount
//                CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
//                updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
//    //            // Ask the overlay view to update just the changed area.
//                [route_views[pos] setNeedsDisplayInMapRect:updateRect];
//                MKCoordinateRegion region=_mapView.region;
//            region.center = newLocation.coordinate;
//                [_mapView setRegion:region animated:YES];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newOverlay:) name:@"newOverlay" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newRect:) name:@"newRect" object:nil];
        path = [[NSMutableArray alloc] init];
        
        line_color = [[NSArray alloc] initWithArray:@[[UIColor redColor],[UIColor greenColor], [UIColor blueColor], [UIColor blackColor], [UIColor whiteColor]]];
        
        ridingManager = [self.tabBarController getRidingManager];
        [ridingManager addTarget:self];
        
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isHeading = FALSE;
    [self setHeading:self];
//    [self setTrackUser:self];
    
    
    if([ridingManager isRiding]){
    
    }
    
   
    
    

        // Do any additional setup after loading the view from its nib.
}




- (IBAction)changeMap:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"일반 지도", @"위성 지도", @"일반 + 위성 지도", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (IBAction)setHeading:(id)sender {
    if(isHeading) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:false];
        isHeading = FALSE;
    }
    else {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:true];
        isHeading = TRUE;
    }
}

- (IBAction)setTrackUser:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:true];
}

- (IBAction)setNoTrack:(id)sender {
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:false];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{

	MKOverlayView* overlayView = nil;
    static int width=1;
    
    for(int i=0; i<[path count]; ++i){
        if(overlay == [path objectAtIndex:i][0]){
            CrumbPathView *view = [path objectAtIndex:i][1];
            
                if(view == [NSNull null])
                {
                    view = [[CrumbPathView alloc] initWithOverlay:overlay];
                    [view setColor:line_color[i]];
                    width+=1;
                    [view setWidth:(double)10/(1<<width)];
                    
                    [[path objectAtIndex:i] replaceObjectAtIndex:1 withObject:view];
                    
                    //view.fillColor = [UIColor redColor];
                    //view.strokeColor = [UIColor redColor];
                    //view.lineWidth = 3;
                }
            overlayView = view;
            break;
        }
    }
    
        return overlayView;

}




- (void)viewDidUnload {
    _mapView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [_mapView release];
    [super dealloc];
}

@end
