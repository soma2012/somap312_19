//
//  AppDelegate.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RidingManager.h"
#import <BugSense-iOS/BugSenseCrashController.h>
#import "NetUtility.h"

//extern NSString *const FBSessionStateChangedNotification;
@class ViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate> 
{

    
}



@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

@end
