//
//  rainsyncTests.m
//  rainsyncTests
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "rainsyncTests.h"

@implementation rainsyncTests

@synthesize window, controller;

- (void)setUp
{
    [super setUp];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)Register
{
    jobfinished=false;
    NetUtility *net =[[NetUtility alloc] initwithBlock:^(int msg, NSDictionary * dic) {
        switch(msg){
            case account_register:{
                NSInteger state=[[dic objectForKey:@"state"] intValue];
                NSInteger uid=[[dic objectForKey:@"uid"] intValue];
                NSString *passkey=[dic objectForKey:@"passkey"];
                NSLog([NSString stringWithFormat:@"STATE %d UID %d PASSKEY %@", state, uid, passkey]);
                STAssertEquals(state, 0, @"account-register fail", nil);
                
                jobfinished = true;
                break;
            }
                
                
        }
    }];
    
    
    [net account_registerwithAcessToken:accessToken withNick:@"" withPhoto:@""];
    [net end];
    
}


- (void)Auth
{
    jobfinished=false;
    NetUtility *net =[[NetUtility alloc] initwithBlock:^(int msg, NSDictionary * dic) {
        switch(msg){
            case account_auth:{
                NSInteger state=[[dic objectForKey:@"state"] intValue];
                sessid=[dic objectForKey:@"sessid"];

                
                NSLog([NSString stringWithFormat:@"STATE %d SESSION %@", state, sessid]);
                STAssertEquals(state, 0, @"account-auth fail", nil);
                jobfinished = true;
                break;
            }
                
                
        }
    }];
    
    
    [net account_auth:accessToken];
    [net end];
    
}

- (void)getProfile
{
    jobfinished=false;
    NetUtility *net =[[NetUtility alloc] initwithBlock:^(int msg, NSDictionary * dic) {
        switch(msg){
            case account_profile_get:{
                NSInteger state=[[dic objectForKey:@"state"] intValue];
                NSString *nick=[dic objectForKey:@"nick"];
                NSString *picture=[dic objectForKey:@"picture"];
                NSString *email=[dic objectForKey:@"email"];
                
                NSLog([NSString stringWithFormat:@"STATE %d NICK %@ PICTURE %@ EMAIL %@", state, nick, picture, email]);
                [controller.profileImageView setImageWithURL:[[[NSURL alloc] initWithString:picture]autorelease]];
                //[controller.profileImageView setImageWithURL:[[[NSURL alloc] initWithString:@"http://i.imgur.com/r4uwx.jpg"]autorelease]];

                STAssertEquals(state, 0, @"get profile fail", nil);
                
                jobfinished = true;
                break;
            }
                
                
        }
    }];
    
    
    [net account_profile_get:sessid];
    [net end];
    
}

-(void)viewSetup{
    window = [[UIApplication sharedApplication] keyWindow];
    controller=[[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
    //[controller.profileImageView setImageWithURL:[[NSURL alloc] initWithString:@"http://i.imgur.com/r4uwx.jpg"]];
    

    
    window.rootViewController =  controller;
    //[controller.profileImageView setImageWithURL:[[[NSURL alloc] initWithString:@"http://i.imgur.com/r4uwx.jpg"]autorelease]];
    accessToken = @"AAAE46WaL6mcBAN6pnhAW4R5SzdZCd3tEHmnrPquouPkWfjDZAgpx7Atgq9GM1FpaTtGHcseZAKVhe9yIyPmZCUT47cKz5QAZChNVoC4ZCfGgZDZD";

    
}

-(void)waitUntilJobFinished
{
    while(!jobfinished)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    return;
    
}

- (void)testExample
{

    
    [self viewSetup];
    //[self Register];
    //[self waitUntilJobFinished];
    [self Auth];
    [self waitUntilJobFinished];
    [self getProfile];
    [self waitUntilJobFinished];
    
    
    
    while(true){
        [[NSRunLoop currentRunLoop] run];
    }
    
     
}

@end
