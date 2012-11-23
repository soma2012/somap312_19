//
//  RidingViewController.h
//  rainsync
//
//  Created by xorox64 on 12. 10. 24..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashBoardViewController.h"
#import "MapViewController.h"
#import "MemberViewController.h"
#import "RidingManager.h"

@interface RidingViewController : UIViewController <UIScrollViewDelegate>
{
    NSMutableArray* controllers;
    @private BOOL pageControlUsed;
    @private int kNumberOfPages;
    RidingManager *ridingManager;

    
    
}

@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@end
