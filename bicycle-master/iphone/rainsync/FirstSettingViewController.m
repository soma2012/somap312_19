//
//  FirstSettingViewController.m
//  rainsync
//
//  Created by 승원 김 on 12. 10. 29..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "FirstSettingViewController.h"
#import "ViewController.h"



@interface FirstSettingViewController ()

@end

@implementation FirstSettingViewController
//@synthesize fbButton, generalLoginButton;
//@synthesize selectFbOrGeneralView, nameAndAvatarSettingView, compeletionSettingView;






- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        net=[[NetUtility alloc] init];

        // Custom initialization

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)fbLogin:(id)sender {
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    [HUD show:TRUE];
    [net RegisterWithFaceBookAndLogin:^(NSError *error) {
        if(error){
            UIAlertView *view= [[UIAlertView alloc] initWithTitle:@"ERROR" message:error.description delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [view show];
            [view release];
        }else{
            ViewController *viewController = [[ViewController alloc] init];
            [[[UIApplication sharedApplication] keyWindow]setRootViewController:viewController];
            [self.view removeFromSuperview];
            [viewController release];
        }
        [HUD hide:YES];
    }];


}



- (IBAction)generalLogin:(id)sender {

    ViewController *viewController = [[ViewController alloc] init];
    [[[UIApplication sharedApplication] keyWindow]setRootViewController:viewController];
    [self.view removeFromSuperview];
    [viewController release];
}

- (void)dealloc {
    [super dealloc];
    [_fbButton release];
    [_generalLoginButton release];
    [_indicator release];
    [net release];
}
- (void)viewDidUnload {
    [self setFbButton:nil];
    [self setGeneralLoginButton:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}



@end
