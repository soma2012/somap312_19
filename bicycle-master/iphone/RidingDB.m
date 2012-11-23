//
//  RidingDB.m
//  rainsync
//
//  Created by xorox64 on 12. 11. 5..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "RidingDB.h"


@implementation RidingDB




-(id)init
{
    // db 생성 및 확인
    NSString *docsDir;
    NSArray *dirPaths;
    NSString *databasePath; // db파일 경로
    
    // documents 디렉토리 확인하기
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // 데이터베이스 파일 경로 구성하기
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"ridings.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    //[filemgr removeItemAtPath:databasePath error:nil];
    const char *dbpath = [databasePath UTF8String];
    if ([filemgr fileExistsAtPath: databasePath] == NO) {
        
        if (sqlite3_open(dbpath, &ridingDB) == SQLITE_OK) {
            
            sqlite3_stmt *statement;
            
            statement = [self getSQLStatement:ridingDB WithQuery:@"CREATE TABLE IF NOT EXISTS RIDINGS (ID INTEGER PRIMARY KEY AUTOINCREMENT, START_DATE REAL, END_DATE REAL, TIME REAL, DISTANCE REAL, SPEED REAL, MAX_SPEED REAL, CALORIE REAL, RIDING_TYPE INTEGER)"];


            //sqlite3_exec 와는 다르게 sqlite3_step은 성공시 sqlite_done을 반환 함으로써 성공을 알린다.
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"Failed to create table");
            }
            
            sqlite3_finalize(statement);
            
            statement = [self getSQLStatement:ridingDB WithQuery:@"CREATE TABLE IF NOT EXISTS LOCATION (ID INTEGER, LATITUDE REAL, LONGITUDE REAL, ALTITUDE REAL, TIME_STAMP REAL, FOREIGN KEY(ID) REFERENCES RIDINGS (ID))"];
            
            if (sqlite3_step(statement)  != SQLITE_DONE) {
                NSLog(@"Failed to create table");
            }
            
            sqlite3_finalize(statement);
            

            
            
            //sqlite3_close(ridingDB);
        }
        else {
             NSLog(@"Failed to open/create database");
            
        }
    }
    else {
         NSLog(@"already exist db");
         sqlite3_open(dbpath, &ridingDB);
        
    }
    
    [databasePath release];
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
    sqlite3_close(ridingDB);
    
}


- (sqlite3_stmt*)getSQLStatement:(sqlite3*)db WithQuery:(NSString*)query{
    sqlite3_stmt *statement;
    const char *str = [query UTF8String];
    int result = sqlite3_prepare_v2(ridingDB, str, -1, &statement, NULL);
    if(result!=0){
        NSLog(@"ERROR %d with query %@", result, query);
        return nil;
    }
    return statement;

}

- (void)saveLocation:(int)row_id withLocation:(NSMutableArray*)locations
{
    
       
       
       

       //(ID INTEGER PRIMARY KEY, LATITUDE REAL, LONGITUDE REAL, ALTITUDE REAL, TIME_STAMP INTEGER, FOREIGN KEY(ID) REFERENCES RIDINGS (ID))
       for (CLLocation * location in locations) {
           sqlite3_stmt *statement2 = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"INSERT INTO LOCATION (ID, LATITUDE, LONGITUDE, ALTITUDE, TIME_STAMP) VALUES (%d, %lf, %lf, %lf, %lf)", row_id, location.coordinate.latitude, location.coordinate.longitude, location.altitude, [location.timestamp timeIntervalSince1970]]];
           
           
           int code= sqlite3_step(statement2);
           sqlite3_finalize(statement2);
       }

       
   
    
   
}

- (int)createRecording:(RidingManager *)manager
{
    sqlite3_stmt *statement;
    
    //(ID INTEGER PRIMARY KEY AUTOINCREMENT, START_DATE REAL, END_DATE REAL, TIME REAL, DISTANCE REAL, SPEED REAL, MAX_SPEED REAL, CALORIE REAL)
    
    statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"INSERT INTO RIDINGS (start_date,end_date, time, distance, speed,max_speed, calorie, riding_type) VALUES (%lf, %lf, %lf, %lf, %lf,%lf, %lf, %d)", [[NSDate date] timeIntervalSince1970], 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, [manager ridingType]]];
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Record Added");
    }
    else {
        NSLog(@"Failed to add Record");
    }
    
    
    sqlite3_finalize(statement);
    
    return sqlite3_last_insert_rowid(ridingDB);

}

- (void)saveRecording:(RidingManager*)manager {
    


    
    sqlite3_stmt *statement;

    //(ID INTEGER PRIMARY KEY AUTOINCREMENT, START_DATE REAL, END_DATE REAL, TIME REAL, DISTANCE REAL, SPEED REAL, MAX_SPEED REAL, CALORIE REAL)
    
        statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"UPDATE RIDINGS SET end_date=%lf, time=%lf, distance=%lf, speed=%lf, max_speed=%lf, calorie=%lf WHERE id=%d", [[NSDate date] timeIntervalSince1970], [manager time], [manager totalDistance], [manager avgSpeed], [manager max_speed], [manager calorie], [manager last_riding]]];
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Record Added");
        }
        else {
            NSLog(@"Failed to add Record");
        }
        
        
        sqlite3_finalize(statement);


}


- (void)deleteRecord:(int)index
{

    sqlite3_stmt *statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"DELETE FROM LOCATION WHERE ID=%d", index]];
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Record deleted");
        }
        else {
            NSLog(@"Failed to delete");
        }
    
    sqlite3_finalize(statement);
    
    statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"DELETE FROM RIDINGS WHERE ID=%d", index]];
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Record deleted");
    }
    else {
        NSLog(@"Failed to delete");
    }
    sqlite3_finalize(statement);
    
}

- (NSMutableArray *)loadRidings
{
    NSMutableArray *ridings = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    
    
    
    //(ID INTEGER PRIMARY KEY AUTOINCREMENT, START_DATE REAL, END_DATE REAL, TIME REAL, DISTANCE REAL, SPEED REAL, MAX_SPEED REAL, CALORIE REAL)
    
    
    statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"SELECT * FROM ridings WHERE end_date>0 ORDER BY id DESC"]];
    
    if (statement) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            int riding_id = sqlite3_column_int(statement, 0);
            [dic setObject:[[[NSNumber alloc]initWithInt:riding_id] autorelease] forKey:@"id"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 1)] autorelease] forKey:@"start_date"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 2)] autorelease] forKey:@"end_date"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 3)] autorelease] forKey:@"time"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 4)] autorelease] forKey:@"distance"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 5)] autorelease] forKey:@"speed"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 6)] autorelease] forKey:@"max_speed"];
            [dic setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 7)] autorelease] forKey:@"calorie"];
            [dic setObject:[[[NSNumber alloc] initWithInt: sqlite3_column_double(statement, 8)] autorelease] forKey:@"riding_type"];
            
            
            [ridings addObject:dic];
            [dic release];
            
            
        }
    }
    else {
        NSLog(@"Match not found");
    }
    sqlite3_finalize(statement);
    
    
    
    return ridings;

}

- (NSMutableDictionary *)loadRiding:(int)index {
    NSMutableDictionary *riding = [[NSMutableDictionary alloc] init];
    
    sqlite3_stmt *statement;

    

    //(ID INTEGER PRIMARY KEY AUTOINCREMENT, START_DATE REAL, END_DATE REAL, TIME REAL, DISTANCE REAL, SPEED REAL, MAX_SPEED REAL, CALORIE REAL)
    
    
        statement = [self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"SELECT * FROM ridings WHERE id=%d LIMIT 1", index]];

        if (statement) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                int riding_id = sqlite3_column_int(statement, 0);
                [riding setObject:[[[NSNumber alloc]initWithInt:riding_id] autorelease] forKey:@"id"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 1)] autorelease] forKey:@"start_date"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 2)] autorelease] forKey:@"end_date"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 3)] autorelease] forKey:@"time"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 4)] autorelease] forKey:@"distance"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 5)] autorelease] forKey:@"speed"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 6)] autorelease] forKey:@"max_speed"];
                [riding setObject:[[[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, 7)] autorelease] forKey:@"calorie"];
                [riding setObject:[[[NSNumber alloc] initWithInt: sqlite3_column_double(statement, 8)] autorelease] forKey:@"riding_type"];

                

                //(ID INTEGER PRIMARY KEY, LATITUDE REAL, LONGITUDE REAL, ALTITUDE REAL, TIME_STAMP REAL
                  
                sqlite3_stmt *statement2 =[self getSQLStatement:ridingDB WithQuery:[NSString stringWithFormat:@"SELECT * FROM location WHERE ID=%d ORDER BY TIME_STAMP ASC", riding_id]];
                NSMutableArray * locations = [[NSMutableArray alloc] init];
                while(sqlite3_step(statement2)== SQLITE_ROW){
                    double lat = sqlite3_column_double(statement2, 1);
                    double lng = sqlite3_column_double(statement2, 2);
                    double alti = sqlite3_column_double(statement2, 3);
                    [locations addObject:[[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng) altitude:alti horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:0 timestamp:[NSDate date]] autorelease]];
                     
                }
                sqlite3_finalize(statement2);

                [riding setObject:locations forKey:@"locations"];
                [locations release];
                
                
                
                
            }            
        }
        else {
            NSLog(@"Match not found");
        }
        sqlite3_finalize(statement);

    
    
    return riding;
}
@end
