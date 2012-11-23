//
//  ViewController.h
//  SlowWorker
//
//  Created by 승원 김 on 12. 11. 3..
//  Copyright (c) 2012년 승원 김. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UITextView *resultsTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImage *primary;
@property (strong, nonatomic) UIImageView *primaryView;
@property (assign, nonatomic) BOOL animate;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

- (IBAction)doWork:(id)sender;
- (void)rotateLabelUp;
- (void)rotateLabelDown;
@end
