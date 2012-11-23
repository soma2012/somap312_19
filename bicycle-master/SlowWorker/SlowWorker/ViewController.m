//
//  ViewController.m
//  SlowWorker
//
//  Created by 승원 김 on 12. 11. 3..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)applicationWillResignActive {
    NSLog(@"VC: %@", NSStringFromSelector(_cmd));
    _animate = NO;
}

- (void)applicationDidBecomeActive {
    NSLog(@"VC: %@", NSStringFromSelector(_cmd));
    _animate = YES;
    [self rotateLabelDown];
}

- (void)applicationDidEnterBackground {
    NSLog(@"VC: %@", NSStringFromSelector(_cmd));
    UIApplication *app = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier taskId;
    taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background task ran out of time and was terminated.");
        [app endBackgroundTask:taskId];
    }];
    
    if (taskId == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task!");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
        _primary = nil;
        _primaryView.image = nil;
    
        NSInteger selectedIndex = _segmentedControl.selectedSegmentIndex;
        [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex forKey:@"selectedIndex"];
        // 오랜 시간(25초)이 걸리는 작업을 시뮬레이션
        [NSThread sleepForTimeInterval:25];
        NSLog(@"Finishing background task with %f seconds remaining", app.backgroundTimeRemaining);
        [app endBackgroundTask:taskId];
    });
}

- (void)applicationWillEnterForeground {
    NSLog(@"VC: %@", NSStringFromSelector(_cmd));
    NSString *primaryPath = [[NSBundle mainBundle] pathForResource:@"primary" ofType:@"jpg"];
    _primary = [UIImage imageWithContentsOfFile:primaryPath];
    _primaryView.image = _primary;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    
    CGRect bounds = self.view.bounds;
    CGRect labelFrame = CGRectMake(bounds.origin.x, CGRectGetMidX(bounds)+150, bounds.size.width, 100);
    _label = [[UILabel alloc] initWithFrame:labelFrame];
    _label.font = [UIFont fontWithName:@"Helvietica" size:70];
    _label.text = @"Primary!";
    _label.textAlignment = UITextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_label];
    
    CGRect primaryFrame = CGRectMake(140, 280, 40, 38);
    _primaryView = [[UIImageView alloc] initWithFrame:primaryFrame];
    _primaryView.contentMode = UIViewContentModeCenter;
    NSString *primaryPath = [[NSBundle mainBundle] pathForResource:@"primaryImg" ofType:@"jpg"];
    _primary = [UIImage imageWithContentsOfFile:primaryPath];
    _primaryView.image = _primary;
    [self.view addSubview:_primaryView];
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", nil]];
    _segmentedControl.frame = CGRectMake(bounds.origin.x + 20, CGRectGetMaxY(bounds) - 50, bounds.size.width - 40, 30);
    [self.view addSubview:_segmentedControl];
    
    NSNumber *indexNumber;
    if (indexNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedIndex"]) {
        NSInteger selectedIndex = [indexNumber intValue];
        _segmentedControl.selectedSegmentIndex = selectedIndex;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doWork:(id)sender {
    _startButton.enabled = NO;
    _startButton.alpha = 0.5f;
    [_spinner startAnimating];
    
    NSDate *startTime = [NSDate date];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    // 항상 존재하는 전역 큐를 호출한다. 첫째인자는 우선 순위를 지정하는 인자고 두번째는 지금 사용하지 않으므로 항상 0으로 지정해야한다.
        NSString *fetchedData = [self fetchSomethingFromServer];
        NSString *processedData = [self processData:fetchedData];
//        NSString *firstResult = [self calculateFirstResult:processedData];
//        NSString *secondResult = [self calculateSecondResult:processedData];
        __block NSString *firstResult;
        __block NSString *secondResult;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            firstResult = [self calculateFirstResult:processedData];
        });
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            secondResult = [self calculateSecondResult:processedData];
        });
        dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
            NSString *resultsSummary = [NSString stringWithFormat:@"First: [%@]\nSecond: [%@]", firstResult, secondResult];
            dispatch_async(dispatch_get_main_queue(), ^{
                _startButton.enabled = YES;
                _startButton.alpha = 1.0f;
                [_spinner stopAnimating];
                _resultsTextView.text = resultsSummary;
            });
            NSDate *endTime = [NSDate date];
            NSLog(@"Completed in %f seconds", [endTime timeIntervalSinceDate:startTime]);
        });
    });
}

- (NSString *)fetchSomethingFromServer {
    [NSThread sleepForTimeInterval:1];
    return @"Hi there";
}

- (NSString *)processData:(NSString *)data {
    [NSThread sleepForTimeInterval:2];
    return [data uppercaseString];
}

- (NSString *)calculateFirstResult:(NSString *)data {
    [NSThread sleepForTimeInterval:3];
    return [NSString stringWithFormat:@"Number of chars: %d", [data length]];
}

- (NSString *)calculateSecondResult:(NSString *)data {
    [NSThread sleepForTimeInterval:4];
    return [data stringByReplacingOccurrencesOfString:@"E" withString:@"e"];
}
- (void)viewDidUnload {
    [self setLabel:nil];
    [super viewDidUnload];
}

- (void)rotateLabelUp {
    [UIView animateWithDuration:0.5
                     animations:^{
                        _label.transform = CGAffineTransformMakeRotation(0);
                     }
                     completion:^(BOOL finished){
                         if (_animate) {
                             [self rotateLabelDown];
                         }
                     }];
}

- (void)rotateLabelDown {
    [UIView animateWithDuration:0.5
                     animations:^{
                         _label.transform = CGAffineTransformMakeRotation(M_PI);
                     }completion:^(BOOL finished){
                         [self rotateLabelUp];
                     }];
}
@end
