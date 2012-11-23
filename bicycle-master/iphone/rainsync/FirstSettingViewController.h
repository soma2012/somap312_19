//
//  FirstSettingViewController.h
//  rainsync
//
//  Created by 승원 김 on 12. 10. 29..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLogin.h"
#import "NetUtility.h"

#import "MBProgressHUD.h"
@interface FirstSettingViewController : UIViewController
{
    NetUtility *net;
    MBProgressHUD *HUD;
}
@property (retain, nonatomic) IBOutlet UIButton *fbButton;
@property (retain, nonatomic) IBOutlet UIButton *generalLoginButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (void)viewWillAppear:(BOOL)animated;

@end
