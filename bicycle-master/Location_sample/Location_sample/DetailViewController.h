//
//  DetailViewController.h
//  Location_sample
//
//  Created by 승원 김 on 12. 11. 6..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *recordingTime;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *altitude;
@property (strong, nonatomic) IBOutlet UILabel *averageSpeed;
@property (strong, nonatomic) IBOutlet UILabel *calorie;

@end
