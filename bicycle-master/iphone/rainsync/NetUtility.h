//
//  NetUtility.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 23..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Queue.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "FBLogin.h"

enum req_type{
    none_req=0,
    account_register=1,
    account_auth=2,
    account_profile_get=3,
    account_friend_list=4,
    race_info=5,
};



@interface NetUtility : AFHTTPClient{
    @private Queue *queue;

    @private NSString *Session;
    @private FBLogin *fblogin;
    
}

-(id)init;
-(void)dealloc;
-(void)accountRegisterWithFaceBook:(NSString*)accesstoken Withblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)accountProfilegGetWithblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)accountAuthWith:(NSString*)accesstoken Withblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)accountFriendListWithblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)raceInfoWithblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)raceInviteWithtarget:(NSMutableArray *)arr Withblock:(void(^)(NSDictionary *res, NSError *error))block;
-(void)addRaceSummaryWitharr:(NSMutableArray *)arr;
-(void)addRaceRecordWithpos:(NSMutableArray*)pos_arr Witharr:(NSMutableArray *)arr;
-(void)postWitharr:(NSMutableArray *)arr Withblock:(void(^)(NSString* msg ,NSMutableDictionary *res, NSError *error))block;
-(void)loginFaceBookWithblock:(void(^)(FBSession *session, NSError* error))block;
-(void)RegisterWithFaceBookAndLogin:(void(^)(NSError* error))block;
-(void)raceEndWithblock:(void(^)(NSDictionary *res, NSError *error))block;
@end
