//
//  DashBoardViewController.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//<CoreLocationControllerDelegate>

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"
#import "RidingManager.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "NetUtility.h"

@interface DashBoardViewController : UIViewController <CoreLocationControllerDelegate>
{
    bool paused;
    bool first;
    BOOL isSingleMode;
    RidingManager *ridingManager;
    NetUtility *net;

}
//@property (nonatomic, retain) NSMutableArray *numberArray;
@property (nonatomic, retain) IBOutlet UIImageView *speedLabel;
@property (nonatomic, retain) IBOutlet UIImageView *avgLabel;
@property (nonatomic, retain) IBOutlet UIImageView *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *calorieLabel;
@property (retain, nonatomic) IBOutlet UIImageView *distanceLabel;
@property (retain, nonatomic) IBOutlet UIButton *stopButton;
@property (retain, nonatomic) IBOutlet UILabel *stopLabel;
@property (retain, nonatomic) IBOutlet UIButton *statusButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIButton *modeChangeButton;
@property (retain, nonatomic) IBOutlet UILabel *modeChangeLabel;
@property (retain, nonatomic) IBOutlet UILabel *modeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *bottom_dashboard;
- (IBAction)modeChange:(id)sender;
@end
