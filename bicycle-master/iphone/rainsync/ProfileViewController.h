//
//  ProfileViewController.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 23..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetUtility.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+AFNetworking.h"
#import "FBLogin.h"
#import "MBProgressHUD.h"

@interface ProfileViewController : UIViewController
{
    NetUtility *net;
    NSString *profilePath;
}
@property (retain, nonatomic) IBOutlet UILabel *Name;
@property (retain, nonatomic) IBOutlet UILabel *Email;
@property (retain, nonatomic) IBOutlet UILabel *Gender;
@property (retain, nonatomic) IBOutlet UILabel *Region;
@property (retain, nonatomic) IBOutlet UILabel *Age;
@property (retain, nonatomic) IBOutlet UILabel *Bike;
@property (retain, nonatomic) IBOutlet UIImageView *profileTexture;

@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UIView *disableView;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editProfileButton;
- (IBAction)login:(id)sender;
- (IBAction)editProfile:(id)sender;
@end
