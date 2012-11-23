//
//  RidingDB.h
//  rainsync
//
//  Created by xorox64 on 12. 11. 5..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import <CoreLocation/CoreLocation.h>
#import "RidingManager.h"

@interface RidingDB : NSObject{
    sqlite3 *ridingDB;

}
- (int)createRecording;
- (void)saveLocation:(int)row_id withLocation:(NSMutableArray*)locations;

//- (void)saveRecording:(RidingManager *)manager;

- (NSMutableArray *)loadRidings;
- (NSMutableDictionary *)loadRiding:(int)index;

- (void)deleteRecord:(int)index;

@end
