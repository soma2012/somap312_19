//
//  ProfileViewController.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 23..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileEditViewController.h"
#import "PrettyKit.h"
#import "UIColor+ColorWithHex.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileViewController




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"내정보", @"내정보");
        net= [self.tabBarController getNetUtility];
        // Custom initialization
        

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    NSString *profileBg = [[NSBundle mainBundle] pathForResource:@"background@2x.jpg" ofType:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:profileBg]];
        
    CALayer *layer = [_profileImageView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:30.0];   // 프로필 사진에 레이어를 씌워 라운딩 처리
    
    [_profileTexture setFrame:CGRectMake(0, self.view.frame.size.height - 180, 320, 230)];
    [_profileTexture setImage:[UIImage imageNamed:@"profileTexture"]];
}

- (IBAction)login:(id)sender {
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
    HUD.dimBackground = YES;
    [HUD show:TRUE];
    
    [net RegisterWithFaceBookAndLogin:^(NSError *error) {
        if(error){
            UIAlertView *view= [[UIAlertView alloc] initWithTitle:@"ERROR" message:error.description delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [view show];
            [view release];
        }else{
            [_disableView setHidden:TRUE];
            [self viewDidAppear:FALSE];
        }
        [HUD hide:TRUE];
    }];
}

- (IBAction)editProfile:(id)sender {
    ProfileEditViewController *profileEditViewController = [[ProfileEditViewController alloc] initWithNibName:@"ProfileEditViewController" bundle:nil];
    profileEditViewController.profile = profilePath;
    profileEditViewController.name = _Name.text;
    profileEditViewController.gender = _Gender.text;
    profileEditViewController.region = _Region.text;
    profileEditViewController.age = _Age.text;
    profileEditViewController.bike = _Bike.text;
    [self.navigationController pushViewController:profileEditViewController animated:YES];
    [profileEditViewController release];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *session =[net getSession];
    if(session)
    {
        [_disableView setHidden:TRUE];
        
        self.navigationItem.rightBarButtonItem = self.editProfileButton;    // 로그인 했을때만 수정 가능
        self.editProfileButton.title = @"수정";

        [net accountProfilegGetWithblock:^(NSDictionary *res, NSError *error) {
            if(error){
                UIAlertView *view= [[UIAlertView alloc] initWithTitle:@"ERROR" message:error.description delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [view show];
                [view release];
            }else{
                
                NSInteger state=[[res objectForKey:@"state"] intValue];

                
                if(state==0){
                    NSString *nick=[res objectForKey:@"nick"];
                    NSString *picture=[res objectForKey:@"picture"];
                    NSString *email=[res objectForKey:@"email"];
                    [_Name setText:nick];
                    [_Email setText:email];
                    profilePath=[[NSURL alloc] initWithString:picture];
                    [_profileImageView setImageWithURL:profilePath];
                    NSLog([NSString stringWithFormat:@"STATE %d NICK %@ PICTURE %@ EMAIL %@", state, nick, picture, email]);
                    
                }else{
                    NSString * msg=[res objectForKey:@"msg"];
                    if(msg){
                    UIAlertView *view= [[UIAlertView alloc] initWithTitle:@"ERROR" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                    [view show];
                    [view release];
                    }
                }
                
            }

        }];

        
        
    }else{
        [_disableView setHidden:FALSE];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_editProfileButton release];    
    [_Name release];
    [_profileImageView release];
    [_disableView release];
    [_loginButton release];
    [_Email release];
    [_Gender release];
    [_Age release];
    [_Region release];
    [_Bike release];
    [_profileTexture release];
    [super dealloc];

}
- (void)viewDidUnload {
    [self setName:nil];
    [self setProfileImageView:nil];
    [self setDisableView:nil];
    [self setLoginButton:nil];
    [self setEmail:nil];
    [self setEditProfileButton:nil];
    [self setGender:nil];
    [self setAge:nil];
    [self setRegion:nil];
    [self setBike:nil];
    [self setProfileTexture:nil];
    [super viewDidUnload];
}


@end
