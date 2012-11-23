//
//  CompletionSettingViewController.m
//  rainsync
//
//  Created by 승원 김 on 12. 10. 29..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "CompletionSettingViewController.h"
#import "ViewController.h"
#import "NameAndAvatarSettingViewController.h"
@interface CompletionSettingViewController ()

@end

@implementation CompletionSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:@"이전" style: UIBarButtonItemStyleBordered target:self action:@selector(goToPrevSetting)];
        self.navigationItem.leftBarButtonItem = prev;
        [prev release];
        
        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"완료" style: UIBarButtonItemStyleDone target:self action:@selector(Done)];
        self.navigationItem.rightBarButtonItem = next;
        [next release];
    }
    return self;
}

- (void)goToPrevSetting{
    [self.navigationController popViewControllerAnimated:FALSE];
    
    //NameAndAvatarSettingViewController *nameAndAvartarSettingViewController = [[NameAndAvatarSettingViewController alloc] initWithNibName:@"NameAndAvatarSettingViewController" bundle:nil];
    //[self.navigationController pushViewController:nameAndAvartarSettingViewController animated:nil];
}

- (void)Done{
    
    ViewController *viewController = [[ViewController alloc] init];
    [[[UIApplication sharedApplication] keyWindow]setRootViewController:viewController];
    [self.view removeFromSuperview];
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

- (void)dealloc {
    [_completionBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCompletionBtn:nil];
    [super viewDidUnload];
}
- (IBAction)completeSetting:(id)sender {
    ViewController *viewController = [[ViewController alloc] init];
    [[[UIApplication sharedApplication] keyWindow]setRootViewController:viewController];
    [self.view removeFromSuperview];
}
@end
