//
//  StaticsViewController.h
//  Location_sample
//
//  Created by 승원 김 on 12. 11. 6..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface StaticsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *array;
    NSMutableArray *recordings;
    
    sqlite3 *ridingDB;  // sqlite 라이딩 데이터베이스 선언
    NSString *databasePath; // db파일 경로
}
@property (strong, nonatomic) NSArray *array;
@property (strong, nonatomic) NSMutableArray *recording;
@end
