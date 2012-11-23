//
//  ViewController.m
//  Location_sample
//
//  Created by 승원 김 on 12. 10. 24..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import "ViewController.h"
#import "StaticsViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize locationManger;
@synthesize latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, distance, resetButton;
@synthesize startLocation;
@synthesize recordingTime;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManger = [[CLLocationManager alloc] init];
    locationManger.desiredAccuracy = kCLLocationAccuracyBest;
    locationManger.delegate = self;
    [locationManger startUpdatingLocation];
    startLocation = nil;
    
    [recordingTime setText:@"00:00:00"];
    isPaused = NO;
    isEnded = NO;
    timeCounter = 0;
    avgSpeed = 0.0f;
    _averageSpeed.text = @"0";
    _highestSpeed.text = @"0";
    
    _resumeRecordBtn.hidden = YES;
    _pauseRecordBtn.hidden = YES;
    _endRecordBtn.hidden = YES;
    
    [_weight setText:@"70"];
    
    
    // db 생성 및 확인
    NSString *docsDir;
    NSArray *dirPaths;
    
    // documents 디렉토리 확인하기
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // 데이터베이스 파일 경로 구성하기
    databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"ridings.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &ridingDB) == SQLITE_OK) {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS RIDINGS (ID INTEGER PRIMARY KEY AUTOINCREMENT, TIME TEXT, DISTANCE TEXT, SPEED TEXT, ALTITUDE TEXT, CALORIE TEXT)";
            if (sqlite3_exec(ridingDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                _dbStatusLabel.text = @"Failed to create table";
                NSLog(@"failed to create table");
            }
            sqlite3_close(ridingDB);
        }
        else {
            _dbStatusLabel.text = @"Failed to open/create database";
        }
    }
    else {
        _dbStatusLabel.text = @"already exist db";
    }
}

- (void)resetDistance
{
    NSLog(@"restDistance is called.");
    startLocation = nil;
}

- (IBAction)startRecording:(id)sender {
    isPaused = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkTime:) userInfo:nil repeats:YES];

    _startRecordBtn.hidden = YES;
    _pauseRecordBtn.hidden = NO;
}

- (IBAction)resumeRecording:(id)sender {
    isPaused = NO;
    _resumeRecordBtn.hidden = YES;
    _pauseRecordBtn.hidden = NO;
}

- (IBAction)pauseRecording:(id)sender {
    isPaused = YES;
    
    _resumeRecordBtn.hidden = NO;
    _endRecordBtn.hidden = NO;
    _pauseRecordBtn.hidden = YES;

}

- (IBAction)endRecording:(id)sender {
    isEnded = NO;
    [_timer invalidate];
    
    _startRecordBtn.hidden = NO;
    _resumeRecordBtn.hidden = YES;
    
    // 결과 출력
    float distanceFloat = [distance.text floatValue];
    NSString *result = [NSString stringWithFormat:@"주행시간: %d\n주행거리: %.2f", timeCounter, distanceFloat];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"기록 측정 완료" message:result delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alert show];
    
    // 초기화
    timeCounter = 0;
    avgSpeed = 0.0f;
    [recordingTime setText:@"00:00:00"];
    [_currentSpeed setText:@"0"];
    [self resetDistance];
}

- (void)saveRidingData {
    sqlite3_stmt *statement;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &ridingDB) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO RIDINGS (time, distance, speed, altitude, calorie) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", recordingTime.text, distance.text, _averageSpeed.text, altitude.text, _calorie.text];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(ridingDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            _dbStatusLabel.text = @"Record Added";
        }
        else {
            _dbStatusLabel.text = @"Failed to add Record";
        }
        sqlite3_finalize(statement);
        sqlite3_close(ridingDB);
    }
}

- (IBAction)saveRecord:(id)sender {
    [self saveRidingData];
}

- (IBAction)loadView:(id)sender {
    StaticsViewController *staticsViewController = [[StaticsViewController alloc] initWithNibName:@"StaticsViewController" bundle:nil];
    UINavigationController *staticsNavViewController = [[UINavigationController alloc] initWithRootViewController:staticsViewController];
    [self.view addSubview:staticsNavViewController.view];
}

- (void)checkTime:(NSTimer *)timer {
    if (isPaused) {
        // 일시정지 중에는 시간이 흐르지 않음
    }
    else if (isPaused == NO) {
        [recordingTime setText:[NSString stringWithFormat:@"%d", ++timeCounter]];
        avgSpeed = ([distance.text floatValue] / 1000.0) / ((float)timeCounter / 3600.0) ;
        [_averageSpeed setText:[NSString stringWithFormat:@"%.6f", avgSpeed]];
        
        [_calorie setText:[NSString stringWithFormat:@"%.6f", [_weight.text intValue] * [self calculateCalorie:avgSpeed] * (timeCounter / 60.0)]];
        NSLog(@"%d", [_weight.text intValue]);
        NSLog(@"%f", [self calculateCalorie:avgSpeed]);
        NSLog(@"%f", timeCounter / 60.0);
    }
}

- (float)calculateCalorie:(float)avgSpd {
    float kcalConstant = 0.0f;
    if (avgSpd <= 13) {
        kcalConstant = 0.065f;
    }
    else if (avgSpd <= 16) {
        kcalConstant = 0.0783f;
    }
    else if (avgSpd <= 19) {
        kcalConstant = 0.0939f;
    }
    else if (avgSpd <= 22) {
        kcalConstant = 0.113f;
    }
    else if (avgSpd <= 24) {
        kcalConstant = 0.124f;
    }
    else if (avgSpd <= 26) {
        kcalConstant = 0.136f;
    }
    else if (avgSpd <= 27) {
        kcalConstant = 0.149f;
    }
    else if (avgSpd <= 29) {
        kcalConstant = 0.163f;
    }
    else if (avgSpd <= 31) {
        kcalConstant = 0.179f;
    }
    else if (avgSpeed <= 32) {
        kcalConstant = 0.196f;
    }
    else if (avgSpeed <= 34) {
        kcalConstant = 0.215f;
    }
    else if (avgSpeed <= 37) {
        kcalConstant = 0.259f;
    }
    else {  // avgSpeed 40km/h 이상
        kcalConstant = 0.311f;
    }
    
    NSLog(@"%f", kcalConstant);
    NSLog(@"아아아..");
    return kcalConstant;
}

- (void)sliderChanged:(id)sender {
	int progressAsInt = (int)(_weightSlider.value + 0.5f);
	NSString *newText = [[NSString alloc]
						 initWithFormat:@"%d",
						 progressAsInt];
	_weight.text = newText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setViewRec:nil];
    [self setHighestSpeed:nil];
    [self setDbStatusLabel:nil];
    [self setSaveRidingBtn:nil];
    [self setWeightSlider:nil];
    [self setWeight:nil];
    [self setCalorie:nil];
    [self setCurrentSpeed:nil];
    [self setCurrentSpeed:nil];
    [self setResumeRecordBtn:nil];
    [self setEndRecordBtn:nil];
    [self setPauseRecordBtn:nil];
    [self setStartRecordBtn:nil];
    self.latitude = nil;
    self.longitude = nil;
    self.horizontalAccuracy = nil;
    self.altitude = nil;
    self.verticalAccuracy = nil;
    self.startLocation = nil;
    self.distance = nil;
    self.locationManger = nil;
    self.recordingTime = nil;
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocation *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSString *currentLatitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.latitude];
    latitude.text = currentLatitude;
    
    NSString *currentLongitude = [[NSString alloc] initWithFormat:@"%g", newLocation.coordinate.longitude];
    longitude.text = currentLongitude;
    
    NSString *currentHorizontalAccuracy = [[NSString alloc] initWithFormat:@"%g", newLocation.horizontalAccuracy];
    horizontalAccuracy.text = currentHorizontalAccuracy;
    
    NSString *currentAltitude = [[NSString alloc] initWithFormat:@"%g", newLocation.altitude];
    altitude.text = currentAltitude;
    
    NSString *currentVerticalAccuracy = [[NSString alloc] initWithFormat:@"%g", newLocation.verticalAccuracy];
    verticalAccuracy.text = currentVerticalAccuracy;
    
    NSString *currentSpeed = [[NSString alloc] initWithFormat:@"%g", newLocation.speed];
    NSString *kmhSpeed = [NSString stringWithFormat:@"%f", [currentSpeed floatValue] * 3.6];    // m/s -> km/h 변환
    
    if ([currentSpeed floatValue] <= -1) {
        _currentSpeed.text = @"Can't check";
    }
    else {
        _currentSpeed.text = kmhSpeed;
        
        if ([kmhSpeed floatValue] > [_highestSpeed.text floatValue]) {
            _highestSpeed.text = kmhSpeed;      // 최고 속도 반영
        }
        
    }
    
    if (startLocation == nil) {
        self.startLocation = newLocation;
    }
    
    CLLocationDistance distanceBetween = [newLocation distanceFromLocation:startLocation];
    NSString *tripString = [[NSString alloc] initWithFormat:@"%f", distanceBetween];
    distance.text = tripString;
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

@end
