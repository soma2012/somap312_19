//
//  MemberViewController.h
//  rainsync
//
//  Created by 승원 김 on 12. 11. 14..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "MemberCustomCell.h"
#import "PrettyKit.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>
#import "Utility.h"
#import "NetUtility.h"
#import "RidingManager.h"

@interface MemberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * participants;
    RidingManager *ridingManager;
    

}
@property (retain, nonatomic) IBOutlet UIView *myView;
@property (retain, nonatomic) IBOutlet UIImageView *myImageView;
@property (retain, nonatomic) IBOutlet UILabel *myNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *mySpeedLabel;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end
