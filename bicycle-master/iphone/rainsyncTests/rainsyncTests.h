//
//  rainsyncTests.h
//  rainsyncTests
//
//  Created by xorox64 on 12. 10. 22..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ProfileViewController.h"
#import "NetUtility.h"

@interface rainsyncTests : SenTestCase
{

    NSInteger worknum;
    NSString* accessToken;
    NSString* sessid;
    NetUtility* net;
    BOOL jobfinished;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ProfileViewController *controller;
//@property NSInteger worknum;
@end
