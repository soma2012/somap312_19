//
//  AppDelegate.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "DashBoardViewController.h"
#import "FirstSettingViewController.h"


#define getNibName(nibName) [NSString stringWithFormat:@"%@%@", nibName, ([UIScreen mainScreen].bounds.size.height == 568)? @"-568":@""]



@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //APNS 에 장치 등록
	//[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	//Badge 개수 설정
	application.applicationIconBadgeNumber = 0;
	    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginWithFacebook:) name:@"loginWithFacebook" object:nil];
    
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"001a166a"];  // add BugSense

    [UIApplication sharedApplication].idleTimerDisabled = YES;  // application can't lock screen automatically


    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    
    //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"session"];
    //[[NSUserDefaults standardUserDefaults]synchronize];
    
    NetUtility *net = [[[NetUtility alloc] init] autorelease];
    
    if([net getSession])
    {
        self.viewController = [[ViewController alloc] init];
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];
        
    }else{
        FirstSettingViewController *firstSettingViewController = [[FirstSettingViewController alloc] initWithNibName:getNibName(@"FirstSettingViewController") bundle:nil];
        self.viewController = firstSettingViewController;
        self.window.rootViewController = self.viewController;
        [self.window makeKeyAndVisible];
    }
    //self.viewController = [[ViewController alloc] init];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{

    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}


//push : APNS 에 장치 등록 성공시 자동실행
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSLog(@"deviceToken : %@", deviceToken);
    [self sendDeviceTokenToRemote:deviceToken];
	/*
	 여기에 당신의 서버와 통신하는 부분을 만들것.
	 푸시를 누구에게 보낼지를 결정하는 것이 바로 deviceToken 값이다.
	 내가 운영할 서버에 deviceToken 를 보내서 보관하자.
	 */
}

//push : APNS 에 장치 등록 오류시 자동실행
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"deviceToken error : %@", error);
}

//push : 어플 실행중에 알림도착
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSDictionary *aps = [userInfo valueForKey:@"aps"];
	NSLog(@"userInfo Alert : %@", [aps valueForKey:@"alert"]);
}


// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of a session object
// the session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}





@end
