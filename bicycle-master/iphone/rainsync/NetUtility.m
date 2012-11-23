//
//  NetUtility.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 23..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "NetUtility.h"


@implementation NetUtility

-(id)init{

    //[super init];

    self = [super initWithBaseURL:[NSURL URLWithString:@"http://api.bicy.kr"]];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    self.parameterEncoding = AFJSONParameterEncoding;
    
    


    fblogin = [[FBLogin alloc] init];
    Session=[self getSession];
    
    return self;
    
}



-(void)dealloc{
    [fblogin dealloc];
    [super dealloc];
}

- (NSString *)getSession
{
    if(Session==nil){
        NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"session"];
        if(saved)
            Session=saved;
    }
    
    return Session;
}


-(void) accountRegisterWithFaceBook:(NSString*)accesstoken Withblock:(void(^)(NSDictionary *res, NSError *error))block{
    [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"account-register", accesstoken] forKeys:@[@"type",@"accesstoken"]] autorelease]  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
    }];

    
}

-(void) accountProfilegGetWithblock:(void(^)(NSDictionary *res, NSError *error))block{
    if(Session){
        [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"account-profile-get", Session] forKeys:@[@"type", @"sid"]] autorelease]  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
        }];
    }
}

-(void) accountAuthWith:(NSString*)accesstoken Withblock:(void(^)(NSDictionary *res, NSError *error))block {

    [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"account-auth", accesstoken] forKeys:@[@"type", @"accesstoken"]] autorelease]  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger state=[[responseObject objectForKey:@"state"] intValue];
        NSString *sessid=[responseObject objectForKey:@"sessid"];
        if(state==0){
            NSLog([NSString stringWithFormat:@"STATE %d SESSION %@", state, sessid]);
            Session = sessid;
            [[NSUserDefaults standardUserDefaults] setObject:Session forKey:@"session"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
        block(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil,error);
    }];


}


-(void) accountFriendListWithblock:(void(^)(NSDictionary *res, NSError *error))block {
    if(Session){
        [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"account-friend-list", Session] forKeys:@[@"type", @"sid"]] autorelease]  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
        }];
    }
}


-(void)raceInfoWithblock:(void(^)(NSDictionary *res, NSError *error))block{
    if(Session){
        [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"race-info", Session] forKeys:@[@"type", @"sid"]] autorelease] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
        }];
    }
}

-(void)raceInviteWithtarget:(NSMutableArray *)arr Withblock:(void(^)(NSDictionary *res, NSError *error))block{
    if(Session){
        [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"race-invite", Session, arr] forKeys:@[@"type", @"sid", @"targets"]] autorelease] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
        }];
    }
}

-(void)raceEndWithblock:(void(^)(NSDictionary *res, NSError *error))block{
    if(Session){
        [self postPath:@"/" parameters:[[[NSDictionary alloc] initWithObjects:@[@"race-end", Session] forKeys:@[@"type", @"sid"]] autorelease] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil,error);
        }];
    }
}

-(void)addRaceSummaryWitharr:(NSMutableArray *)arr{
    [arr addObject:[[[NSDictionary alloc] initWithObjects:@[@"race-summary", Session] forKeys:@[@"type", @"sid"]] autorelease]];
    return;
}

-(void)addRaceRecordWithpos:(NSMutableArray*)pos_arr Witharr:(NSMutableArray *)arr
{
        NSMutableArray *buf =[[[NSMutableArray alloc] init] autorelease];
        for (CLLocation *loc in pos_arr) {            
            
            [buf addObject:[NSString stringWithFormat:@"%lf,%lf,%lf",loc.coordinate.latitude, loc.coordinate.longitude, loc.speed]];
        }
        NSDictionary * dic=[[[NSDictionary alloc] initWithObjects:@[@"race-record", Session,buf] forKeys:@[@"type", @"sid", @"pos"]] autorelease];
        [arr addObject:dic];
                        
        return;

}

-(void)postWitharr:(NSMutableArray *)arr Withblock:(void(^)(NSString* msg ,NSMutableDictionary *res, NSError *error))block
{
    if(Session){
        Queue *queue = [[Queue alloc] init];
        
        for (NSDictionary *dic in arr) {
            [queue push:[dic objectForKey:@"type"]];
        }
        
        [self postPath:@"/" parameters:arr success:^(AFHTTPRequestOperation *operation, id responseObject) {
            for (int i=0; i<[queue count]; i++) {
                block([queue pop], responseObject[i], nil);
            }
            [queue release];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(@"", nil,error);
            [queue release];
        }];
    }
}


-(void)loginFaceBookWithblock:(void(^)(FBSession *session, NSError* error))block
{
    [fblogin openSessionWithAllowLoginUI:TRUE Withblock:block];
}

-(void)RegisterWithFaceBookAndLogin:(void(^)(NSError* error))block
{
    [self loginFaceBookWithblock:^(FBSession *session, NSError *error) {
        if(error){
            block(error);
        }else{
            [self accountRegisterWithFaceBook:session.accessToken Withblock:^(NSDictionary *res, NSError *error) {
                if(error)
                {
                    block(error);
                }else{
                    [self accountAuthWith:session.accessToken Withblock:^(NSDictionary *res, NSError *error) {
                        block(nil);
                    }];
                }
            }];
        }
        
        
    }];
}


@end