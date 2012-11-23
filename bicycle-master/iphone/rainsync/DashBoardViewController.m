//
//  DashBoardViewController.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "DashBoardViewController.h"
#import "GroupRideViewController.h"
#import "PrettyKit.h"

@interface DashBoardViewController ()

@end

@implementation DashBoardViewController

@synthesize speedLabel, avgLabel, timeLabel, calorieLabel, distanceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        first=true;
        net = [self.tabBarController getNetUtility];
        ridingManager=[self.tabBarController getRidingManager];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invited:) name:@"invited" object:nil];
        
        // Custom initialization
    }
    return self;
}





- (void)locationManager:(RidingManager *)manager
{
    

    
    if([manager current_location].speed == -1)
        speedLabel.image = [Utility numberImagify:@"0.0"];
    else
        speedLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [Utility mpsTokph:[manager current_location].speed]]];
    
    

    calorieLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [manager calorie] ]];
    distanceLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [Utility metreTokilometre:[manager totalDistance]]]];
    
    
    calorieLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [manager calorie] ]];
    distanceLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [Utility metreTokilometre:[manager totalDistance]]]];
    

}

- (void)updateTime:(RidingManager*)manager
{
    
    avgLabel.image = [Utility numberImagify:[NSString stringWithFormat:@"%.1lf", [Utility mpsTokph:[manager avgSpeed]]]];
    timeLabel.image = [Utility numberImagify:[Utility getStringTime:[manager time]]];
    

}






- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    
}



- (IBAction)stopRiding:(id)sender {
    paused = false;
    if([ridingManager ridingType]==0){
        [self.statusButton setImage:[UIImage imageNamed:@"startSingleRiding"] forState:UIControlStateNormal];
    }else{
        [self.statusButton setImage:[UIImage imageNamed:@"startGroupRiding"] forState:UIControlStateNormal];
    }
    
    [ridingManager stopRiding];
    timeLabel.image = [Utility numberImagify:@"00:00:00"];
    speedLabel.image = [Utility numberImagify:@"0.0"];
    distanceLabel.image = [Utility numberImagify:@"0.0"];
    avgLabel.image = [Utility numberImagify:@"0.0"];
    speedLabel.image = [Utility numberImagify:@"0.0"];
    calorieLabel.image = [Utility numberImagify:@"0.0"];
    [self.stopButton setEnabled:NO];
    [self.stopLabel setAlpha:0.5f];
    

}

//- (void)invited:(NSNotification*)noti{
//    BOOL isInvited =[[[noti userInfo] objectForKey:@"isInvited"] boolValue];
//    
//    if(isInvited)
//    {
//        paused=true;
//        [ridingManager loadStatus];
//        [ridingManager startRiding];
//        [self.statusLabel setText:@"멈추기"];
//        [self.stopButton setEnabled:NO];
//        [self.stopLabel setAlpha:0.5f];
//    }else{
//        
//    }
//}

- (IBAction)statusChanged:(id)sender {

    NSLog(@"%d", [ridingManager isRiding]);
    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"RidingType"]);

    //start!
    if(!paused){
        if([ridingManager ridingType]==0)
        {
            [self.statusButton setImage:[UIImage imageNamed:@"pauseSingleRiding"] forState:UIControlStateNormal];
            paused=true;
            [ridingManager loadStatus];
            [ridingManager startRiding];
            [self.statusLabel setText:@"멈추기"];
            [self.stopButton setEnabled:NO];
            [self.stopLabel setAlpha:0.5f];
            
        }else{
            [self.statusButton setImage:[UIImage imageNamed:@"pauseGroupRiding"] forState:UIControlStateNormal];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
            hud.dimBackground=TRUE;
            [hud show:TRUE];
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"RidingType"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            [net raceInfoWithblock:^(NSDictionary *res, NSError *error) {
                if(error){
                    UIAlertView *view= [[UIAlertView alloc] initWithTitle:@"ERROR" message:error.description delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                    [view show];
                    [view release];
                }else{
                    
                    NSInteger state=[[res objectForKey:@"state"] intValue];
                    NSMutableArray *participants=[res objectForKey:@"participants"];
                    
                    
                    if(state==0){
                        if([participants count]==0){
                            GroupRideViewController *groupRideViewController = [[GroupRideViewController alloc] initWithNibName:@"GroupRideViewController" bundle:nil];
                            //[self presentModalViewController:groupRideViewController animated:YES];
                            [self presentViewController:groupRideViewController animated:TRUE completion:nil];
                                                       
                            
                            //[groupRideViewController initWithNibName:@"GroupRideViewController" bundle:nil];
                            [groupRideViewController release];
                            

                            
                        }else{
                            paused=true;
                            [ridingManager loadStatus];
                            [ridingManager startRiding];
                            [self.statusLabel setText:@"멈추기"];
                            [self.stopButton setEnabled:NO];
                            [self.stopLabel setAlpha:0.5f];
                            
                            [self.parentViewController setPage:2];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"raceInit" object:nil userInfo:participants];
                            
                            
                        }
                        
                        
                    }else{
                        
                    }
                    [hud hide:TRUE];
                    
                }

            }];
        }
        

        
        
    //pause!
    }else{
        if([ridingManager ridingType]==0)
        {
            [self.statusButton setImage:[UIImage imageNamed:@"startSingleRiding"] forState:UIControlStateNormal];
            [self.statusLabel setText:@"혼자 달리기"];
        }
        else{
            [self.statusButton setImage:[UIImage imageNamed:@"startGroupRiding"] forState:UIControlStateNormal];
            [self.statusLabel setText:@"같이 달리기"];
            
        }
        
        [ridingManager pauseRiding];
        paused =false;

        [self.stopButton setEnabled:YES];
        [self.stopLabel setAlpha:1.0f];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
NSInteger type = [ridingManager ridingType];

    if (type==0) {
        [_modeLabel setText:@"Single Riding"];
        [self.statusLabel setText:@"혼자 달리기"];
        [_stopButton setImage:[UIImage imageNamed:@"stopSingleRiding"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"startSingleRiding"] forState:UIControlStateNormal];
    }
    else if(type==1){
        [_modeLabel setText:@"Group Riding"];
        [self.statusLabel setText:@"같이 달리기"];
        [_stopButton setImage:[UIImage imageNamed:@"stopGroupRiding"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"startGroupRiding"] forState:UIControlStateNormal];
        
        CABasicAnimation* rotationAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation2.removedOnCompletion = NO;
        rotationAnimation2.fillMode = kCAFillModeForwards;
        rotationAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rotationAnimation2.delegate = self;
        rotationAnimation2.fromValue = [NSNumber numberWithInt:0];
        rotationAnimation2.toValue = [NSNumber numberWithFloat:M_PI_2];//(1 * M_PI) * direction];
        rotationAnimation2.duration = 0.5f;
        [_modeChangeButton.imageView addAnimation:rotationAnimation2 forKey:@"rotateAnimation"];
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{

    
    if(first){
        timeLabel.image = [Utility numberImagify:@"00:00:00"];
        speedLabel.image = [Utility numberImagify:@"0.0"];
        distanceLabel.image = [Utility numberImagify:@"0.0"];
        avgLabel.image = [Utility numberImagify:@"0.0"];
        speedLabel.image = [Utility numberImagify:@"0.0"];
        calorieLabel.image = [Utility numberImagify:@"0.0"];
        

    
    [ridingManager addTarget:self];
    if([ridingManager isRiding]){
        UIAlertView *view=[[UIAlertView alloc] initWithTitle:@"알림" message:@"이전 라이딩을 불러오시겠습니까?"  delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"네", nil];
        [view show];
        [view release];
        
    }
    else {
        [_stopButton setEnabled:NO];    // 처음 시작이면 정지버튼 비활성
        [_stopLabel setAlpha:0.5f];
    }
    paused = false;
    first=false;
        
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    

    [ridingManager loadStatus];
    switch (buttonIndex) {
        case 0:
        {
            [ridingManager stopRiding];
//            [_stopButton setEnabled:NO];
//            [_stopLabel setAlpha:0.5f];
            break;
        }
        case 1:
        {
            
            [self locationManager:ridingManager];
            [self updateTime:ridingManager];
            break;
            
            
        }
    }
    
    
    
}


- (void)dealloc {
    [speedLabel release];
    [avgLabel release];
    [timeLabel release];
    [calorieLabel release];
    [_stopButton release];
    [_statusButton release];
    [distanceLabel release];
    [_statusLabel release];
    [_stopLabel release];
    [_modeChangeButton release];
    [_modeLabel release];
    [_bottom_dashboard release];
    [_modeChangeLabel release];
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCalorieLabel:nil];
    [self setStopButton:nil];
    [self setStatusButton:nil];
    [self setStopButton:nil];
    [self setDistanceLabel:nil];
    [self setStatusLabel:nil];
    [self setStopLabel:nil];
    [self setModeChangeButton:nil];

    [self setTest:nil];
    [self setModeLabel:nil];
    [self setBottom_dashboard:nil];
    [self setModeChangeLabel:nil];
    [super viewDidUnload];
}

- (IBAction)modeChange:(id)sender {
    
    //라이딩 시에는 모드를 바꿀 수 없게 함
    if(paused || [ridingManager isRiding])
        return;
    
    NSInteger type = [ridingManager ridingType];
        
    CABasicAnimation* rotationAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation2.removedOnCompletion = NO;
    rotationAnimation2.fillMode = kCAFillModeForwards;
    rotationAnimation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation2.delegate = self;
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.delegate = self;
    
    if (type==0) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"RidingType"];
        
        rotationAnimation.fromValue = [NSNumber numberWithInt:0];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];//(1 * M_PI) * direction];
        rotationAnimation.duration = 0.5f;
        [_stopButton addAnimation:rotationAnimation forKey:@"rotateAnimation"];
        [_statusButton addAnimation:rotationAnimation forKey:@"rotateAnimation"];
        
        [_stopButton setImage:[UIImage imageNamed:@"stopGroupRiding"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"startGroupRiding"] forState:UIControlStateNormal];
        [_modeLabel setText:@"Group Riding"];
        [self.statusLabel setText:@"같이 달리기"];
                
        rotationAnimation2.fromValue = [NSNumber numberWithInt:0];
        rotationAnimation2.toValue = [NSNumber numberWithFloat:M_PI_2];//(1 * M_PI) * direction];
        rotationAnimation2.duration = 0.5f;
        [_modeChangeButton.imageView addAnimation:rotationAnimation2 forKey:@"rotateAnimation"];
    }
    else if(type==1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"RidingType"];

        rotationAnimation.fromValue = [NSNumber numberWithFloat:M_PI * 2];
        rotationAnimation.toValue = [NSNumber numberWithInt:0];//(1 * M_PI) * direction];
        rotationAnimation.duration = 0.5f;
        [_stopButton addAnimation:rotationAnimation forKey:@"rotateAnimation"];
        [_statusButton addAnimation:rotationAnimation forKey:@"rotateAnimation"];
        
        [_stopButton setImage:[UIImage imageNamed:@"stopSingleRiding"] forState:UIControlStateNormal];
        [_statusButton setImage:[UIImage imageNamed:@"startSingleRiding"] forState:UIControlStateNormal];
        [_modeLabel setText:@"Single Riding"];
        [self.statusLabel setText:@"혼자 달리기"];
        
        rotationAnimation2.fromValue = [NSNumber numberWithFloat:M_PI_2];
        rotationAnimation2.toValue = [NSNumber numberWithInt:0];//(1 * M_PI) * direction];
        rotationAnimation2.duration = 0.5f;
        [_modeChangeButton.imageView addAnimation:rotationAnimation2 forKey:@"rotateAnimation"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.parentViewController refreshPageControl];
    
}

@end
