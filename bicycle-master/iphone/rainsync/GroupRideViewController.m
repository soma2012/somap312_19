//
//  GroupRideViewController.m
//  rainsync
//
//  Created by xorox64 on 12. 10. 24..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "GroupRideViewController.h"
#import "PrettyKit.h"

@interface GroupRideViewController ()

@end

#define start_color [UIColor colorWithHex:0xEEEEEE]
#define end_color [UIColor colorWithHex:0xDEDEDE]

static NSString *kInvitePartialTitle = @"초대 (%d)";


@implementation GroupRideViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _selectedUserArray = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"구성원 초대";
    self.userTableView.rowHeight = 60;
    self.userTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    NSString *bgPath = [[NSBundle mainBundle] pathForResource:@"background-568@2x.png" ofType: nil];
    self.userTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:bgPath]];
    
    self.userTableView.allowsMultipleSelection = YES;  // 복수선택 가능

    [self.userTableView dropShadows];
    [_inviteButton setEnabled:FALSE];
    
    NetUtility *net =[[NetUtility alloc] init];
    
    [net accountFriendListWithblock:^(NSDictionary *res, NSError *error) {
        NSInteger state=[[res objectForKey:@"state"] intValue];
        
        if(state==0){
            NSMutableArray *friends=[res objectForKey:@"friends"];
            for (NSMutableDictionary *dic in friends) {
                [_selectedUserArray addObject:dic];
                [_userTableView reloadData];
            }
            
            
        }
        [net release];
        
    }];
    

}
    
- (void)viewWillAppear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:animated];

    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

-(void)onDoneClick:(id)sender
{
    // 선택된 유저 초대 푸쉬 보내고 서버 접속 유도
    [self dismissModalViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_userTableView release];
    [_inviteButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUserTableView:nil];
    [self setInviteButton:nil];
    [super viewDidUnload];
}

- (IBAction)inviteUser:(id)sender {
    // open a dialog with just an OK button
	NSString *actionTitle = @"선택하신 이용자에게 초대 메세지를 보내시겠습니까?";
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:@"아니오"
                                               destructiveButtonTitle:@"네"
                                                    otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
	[actionSheet release];
}


- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:TRUE];
//    NSDictionary *dic =[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithBool:FALSE]] forKeys:@[@"isInvited"]];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"invited" object:nil userInfo:dic];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            MBProgressHUD *HUD=[MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
            [HUD show:TRUE];
            NSMutableArray *arr = [[[NSMutableArray alloc] init] autorelease];
            for (NSIndexPath *path in [_userTableView indexPathsForSelectedRows]) {
                [arr addObject:[[_selectedUserArray objectAtIndex:[_userTableView cellForRowAtIndexPath:path].tag] objectForKey:@"uid"]];
            }
            
            NetUtility *net =[[NetUtility alloc] init];
            [net raceInviteWithtarget:arr Withblock:^(NSDictionary *res, NSError *error) {
                if(error)
                {
                    
                }else{
                    NSInteger state= [[res objectForKey:@"state"] intValue];
                    if(state==0)
                    {
                        [self dismissModalViewControllerAnimated:FALSE];
//                        NSDictionary *dic =[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithBool:TRUE]] forKeys:@[@"isInvited"]];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"invited" object:nil userInfo:dic];

                    }
                }
                
                [net release];
                [HUD hide:TRUE];
            }];
            //예 버튼
            
            break;
        }
        case 1:
            //아니오 버튼
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Action Sheet Delegate

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//	// the user clicked one of the OK/Cancel buttons
//	if (buttonIndex == 0)
//	{
//        NSArray *selectedRows = [self.userTableView indexPathsForSelectedRows];
//        if (selectedRows.count > 0)
//        {
//            for (NSIndexPath *selectionIndex in selectedRows)
//            {
//                NSLog(@"%d", selectionIndex.row);
//            }
//        }
//    }
//    else {
//        
//    }
//}

#pragma mark -
#pragma mark Table view DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_selectedUserArray count];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight + [PrettyTableViewCell tableView:tableView neededHeightForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    PrettyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.tableViewBackgroundColor = tableView.backgroundColor;
        cell.gradientStartColor = start_color;
        cell.gradientEndColor = end_color;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;    // 셀 선택 시 하이라이트 효과 해제
    }
    [cell prepareForTableView:tableView indexPath:indexPath];

    NSDictionary *dic=[_selectedUserArray objectAtIndex:indexPath.row];
    
	cell.textLabel.text = [dic objectForKey:@"nick"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.tag =indexPath.row;
    
   
    
    //cell.imageView.frame=rect;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"picture"]] placeholderImage:[UIImage imageNamed:@"nobody.jpg"]];
    
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [self.userTableView indexPathsForSelectedRows];
    NSString *inviteButtonTitle = [NSString stringWithFormat:kInvitePartialTitle, selectedRows.count];
    
    [_inviteButton setEnabled:YES];
    _inviteButton.title = inviteButtonTitle;

    [self.userTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [self.userTableView indexPathsForSelectedRows];
    NSString *inviteButtonTitle = [NSString stringWithFormat:kInvitePartialTitle, selectedRows.count];
    [self.userTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;

    if (selectedRows.count != 0) {
        _inviteButton.title = inviteButtonTitle;

    }
    else {
        _inviteButton.title = @"초대";
        [_inviteButton setEnabled:FALSE];
        
    }
}


@end
