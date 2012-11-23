//
//  Login.m
//  rainsync
//
//  Created by xorox64 on 12. 11. 14..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "FBLogin.h"

@implementation FBLogin


- (id)init
{
    [super init];
    return self;
}



-(void)dealloc
{
    [super dealloc];
}



/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {
                end(session, nil);
                // We have a valid session
                NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            //[FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    
    
    
    if(error){
        end(nil,error);
    }

    Block_release(end);
    
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI Withblock:(void(^)(FBSession *session, NSError* error))block{
    end = Block_copy(block);
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

@end
