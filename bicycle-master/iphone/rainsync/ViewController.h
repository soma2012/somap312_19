//
//  ViewController.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "GroupRideViewController.h"
#import "RidingViewController.h"
#import "StaticViewController.h"
#import "SettingViewController.h"


@interface ViewController : UITabBarController //<UIAppearance>
{
    RidingManager *ridingManager;
    NetUtility *net;
    
}
- (void) changeToRiding;
@end
