//
//  CompletionSettingViewController.h
//  rainsync
//
//  Created by 승원 김 on 12. 10. 29..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompletionSettingViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *completionBtn;
- (IBAction)completeSetting:(id)sender;
- (void) Done;
- (void) goToPrevSetting;
@end
