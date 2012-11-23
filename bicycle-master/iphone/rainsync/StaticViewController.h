//
//  GroupRideViewController.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 24..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RidingDB.h"
@interface StaticViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    RidingDB *ridingdb;
    NSMutableArray *recordings;
}
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *recordings;
@end
