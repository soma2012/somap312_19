//
//  RidingViewController.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 24..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "RidingViewController.h"
#define getNibName(nibName) [NSString stringWithFormat:@"%@%@", nibName, ([UIScreen mainScreen].bounds.size.height == 568)? @"-568":@""]

@interface RidingViewController ()

@end

@implementation RidingViewController

@synthesize scrollView, pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"라이딩", @"라이딩");
        UIImage *img = [UIImage imageNamed:@"bikeIcon"];
        [self.tabBarItem setImage:img];
        
        ridingManager = [self.tabBarController getRidingManager];
        // Custom initialization
    }
    return self;
}

- (void)refreshPageControl{
    NSInteger type = [ridingManager ridingType];
    if(type==0){
        kNumberOfPages=2;
        UIViewController *controller=[controllers objectAtIndex:2];
        if(controller!=[NSNull null])
            [controller.view setHidden:TRUE];
    }
    else if(type==1){
     
        kNumberOfPages=3;
        UIViewController *controller=[controllers objectAtIndex:2];
        if(controller!=[NSNull null])
            [controller.view setHidden:FALSE];
    
    }
    pageControl.numberOfPages = kNumberOfPages;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    
}

- (void)initPageControl
{
    
    NSInteger type = [ridingManager ridingType];
    if(type==0)
        kNumberOfPages=2;
    else if(type==1)
        kNumberOfPages=3;
    
    
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < 3; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    
    
    
    
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    pageControl.numberOfPages = kNumberOfPages;
    pageControl.currentPage = 0;
    
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}


- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [controllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        switch (page) {
            case 0:
                controller = [DashBoardViewController alloc];       
                break;
                
            case 1:
                controller = [MapViewController alloc];          
                break;
            case 2:
                controller = [MemberViewController alloc];        
            default:
                break;
        }
        
        [self addChildViewController:controller];
        
        switch (page) {
            case 0:
                [controller initWithNibName:getNibName(@"DashBoardViewController") bundle:nil];
                break;
            case 1:
                [controller initWithNibName:@"MapViewController" bundle:nil];
                break;
            case 2:
                [controller initWithNibName:@"MemberViewController" bundle:nil];
            default:
                break;
        }
        
        [controllers replaceObjectAtIndex:page withObject:controller];
        [self addChildViewController:controller];
        [controller release];
    }
    
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;

    
    //page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)setPage:(int)page
{
    pageControl.currentPage=page;
    [self changePage:self];
}

- (IBAction)changePage:(id)sender
{
    
    
    int page = pageControl.currentPage;

    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (void)viewWillAppear:(BOOL)animated
{

    
    
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:true];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:false];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self initPageControl];

    

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
