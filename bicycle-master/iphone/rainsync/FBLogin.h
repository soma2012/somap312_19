//
//  Login.h
//  rainsync
//
//  Created by xorox64 on 12. 11. 14..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBLogin : NSObject
{

    @private void (^end)(FBSession *session, NSError* error);
    
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI Withblock:(void(^)(FBSession *session, NSError* error))block;
@end
