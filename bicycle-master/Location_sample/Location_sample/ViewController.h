//
//  ViewController.h
//  Location_sample
//
//  Created by 승원 김 on 12. 10. 24..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>    //sqlite3 헤더파일 추가

@interface ViewController : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>
{
    CLLocationManager *locationManger;
    UILabel *latitude;
    UILabel *longitude;
    UILabel *horizontalAccuracy;
    UILabel *altitude;
    UILabel *verticalAccuracy;
    UILabel *distance;
    UIButton *resetButton;
    CLLocation *startLocation;
    
    UILabel *recordingTime;
    NSTimer *_timer;    // 타이머 변수
    BOOL isPaused;      // 라이딩이 일시중지인지 체크
    BOOL isEnded;       // 라이딩이 끝났는지 체크
    int timeCounter;    // 시간 카운터
    float avgSpeed;     // 평균속도
    
    sqlite3 *ridingDB;  // sqlite 라이딩 데이터베이스 선언
    NSString *databasePath; // db파일 경로

}
@property (strong, nonatomic) CLLocationManager *locationManger;
@property (strong, nonatomic) CLLocation *startLocation;

@property (strong, nonatomic) IBOutlet UILabel *latitude;
@property (strong, nonatomic) IBOutlet UILabel *longitude;
@property (strong, nonatomic) IBOutlet UILabel *horizontalAccuracy;
@property (strong, nonatomic) IBOutlet UILabel *altitude;
@property (strong, nonatomic) IBOutlet UILabel *verticalAccuracy;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *recordingTime;
@property (strong, nonatomic) IBOutlet UILabel *currentSpeed;
@property (strong, nonatomic) IBOutlet UILabel *averageSpeed;
@property (strong, nonatomic) IBOutlet UILabel *highestSpeed;
@property (strong, nonatomic) IBOutlet UILabel *calorie;

@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UIButton *startRecordBtn;
@property (strong, nonatomic) IBOutlet UIButton *resumeRecordBtn;
@property (strong, nonatomic) IBOutlet UIButton *pauseRecordBtn;
@property (strong, nonatomic) IBOutlet UIButton *endRecordBtn;
@property (strong, nonatomic) IBOutlet UISlider *weightSlider;
@property (strong, nonatomic) IBOutlet UILabel *weight;

@property (strong, nonatomic) IBOutlet UILabel *dbStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *saveRidingBtn;
@property (strong, nonatomic) IBOutlet UIButton *viewRec;

- (IBAction)resetDistance;
- (IBAction)startRecording:(id)sender;  // 기록 측정 시작 이벤트
- (IBAction)resumeRecording:(id)sender; // 기록 측정 재개 이벤트
- (IBAction)pauseRecording:(id)sender;  // 기록 측정 일시중지 이벤트
- (IBAction)endRecording:(id)sender;    // 기록 측정 완료 이벤트
- (IBAction)sliderChanged:(id)sender;   // 몸무게 설정 슬라이더
- (IBAction)saveRecord:(id)sender;      // 측정된 기록 데이터베이스에 저장 이벤트
- (IBAction)loadView:(id)sender;

- (void)checkTime:(NSTimer *)timer;     // 기록 측정 시간 카운터 동작 메서드
- (void)saveRidingData; // 기록 저장 메서드 선언

@end
