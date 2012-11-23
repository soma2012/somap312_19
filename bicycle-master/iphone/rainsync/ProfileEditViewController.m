//
//  ProfileEditViewController.m
//  rainsync
//
//  Created by 승원 김 on 12. 10. 31..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "PrettyKit.h"
#import "UIColor+ColorWithHex.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"내 정보 수정";

        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:@"취소" style: UIBarButtonItemStyleBordered target:self action:@selector(cancelAndBack)];
        self.navigationItem.leftBarButtonItem = prev;
        [prev release];
        
        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"완료" style: UIBarButtonItemStyleBordered target:self action:@selector(saveEditProfile)];
        self.navigationItem.rightBarButtonItem = next;
        [next release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([_gender isEqualToString:@"남자"]) {
        [_genderSegment setSelected:0];
    } else {
        [_genderSegment setSelected:1];
    }
    [_profileImageView setImageWithURL:[[NSURL alloc] initWithString:_profile]];
    [_nameTextField setText:[NSString stringWithFormat:@"%@", _name]];
    [_ageLabel setText:[NSString stringWithFormat:@"%@", _age]];
    [_regionLabel setText:[NSString stringWithFormat:@"%@", _region]];
    [_bikeLabel setText:[NSString stringWithFormat:@"%@", _bike]];
    
    [self createAgePicker];
	[self createRegionPicker];
	[self createBikePicker];
}

#pragma mark -
#pragma mark UIPickerView

// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
                                   screenRect.size.height - 42.0 - size.height + 52,
                                   size.width,
                                   size.height - 44);
	return pickerRect;
}

- (void)createAgePicker
{
	_ageArray = [[NSArray alloc] initWithObjects:@"10대", @"20대", @"30대", @"40대", @"50대", @"60대 이상", nil];
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	_agePickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	_agePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	CGSize pickerSize = [_agePickerView sizeThatFits:CGSizeZero];
	_agePickerView.frame = [self pickerFrameWithSize:pickerSize];
    
	_agePickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	_agePickerView.delegate = self;
	_agePickerView.dataSource = self;
	
	// add this picker to our view controller, initially hidden
	_agePickerView.hidden = YES;
	[self.view addSubview:_agePickerView];
}

- (void)createRegionPicker
{
	_regionArray = [[NSArray alloc] initWithObjects:@"서울", @"경기", @"인천", @"충북", @"충남", @"대전", @"강원", @"경북", @"경남", @"대구", @"부산", @"전북", @"전남", @"광주", @"제주", @"해외", nil];
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	_regionPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	_regionPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	CGSize pickerSize = [_regionPickerView sizeThatFits:CGSizeZero];
	_regionPickerView.frame = [self pickerFrameWithSize:pickerSize];
    
	_regionPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	_regionPickerView.delegate = self;
	_regionPickerView.dataSource = self;
	
	// add this picker to our view controller, initially hidden
	_regionPickerView.hidden = YES;
	[self.view addSubview:_regionPickerView];
}

- (void)createBikePicker
{
	_bikeArray = [[NSArray alloc] initWithObjects:@"로드", @"하이브리드", @"픽시", @"산악", nil];
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	_bikePickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	
	_bikePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	CGSize pickerSize = [_bikePickerView sizeThatFits:CGSizeZero];
	_bikePickerView.frame = [self pickerFrameWithSize:pickerSize];
    
	_bikePickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	_bikePickerView.delegate = self;
	_bikePickerView.dataSource = self;
	
	// add this picker to our view controller, initially hidden
	_bikePickerView.hidden = YES;
	[self.view addSubview:_bikePickerView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelAndBack;
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveEditProfile
{
    // 저장하는 로직 구현
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Actions

- (void)showPicker:(UIView *)picker
{
	// hide the current picker and show the new one
	if (_currentPicker)
	{
		_currentPicker.hidden = YES;
    }
	picker.hidden = NO;
	
	_currentPicker = picker;	// remember the current picker so we can remove it later when another one is chosen
}

- (IBAction)hidePicker:(id)sender {
    _currentPicker.hidden = !_currentPicker.hidden;
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [_nameTextField resignFirstResponder];
}

-(IBAction)toggleControls: (id)sender {
	if([sender selectedSegmentIndex] == 0) {
        _gender = [NSString stringWithFormat:@"남자"];
	} else {
        _gender = [NSString stringWithFormat:@"여자"];
	}
}

//- (IBAction)selectBikeDone:(id)sender {
//    [self showPicker:_bikePickerView];
//}

- (IBAction)selectAge:(id)sender {
    [self showPicker:_agePickerView];
}

- (IBAction)selectRegion:(id)sender {
    [self showPicker:_regionPickerView];
}

- (IBAction)selectBike:(id)sender {
    [self showPicker:_bikePickerView];
}

#pragma mark -
#pragma mark Camera delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //        imageView.image = image;
        
        // 프로필 사진 버튼의 이미지를 선택된 사진으로 지정
        [_profileImageBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_profileImageBtn setBackgroundImage:image forState:UIControlStateHighlighted];
        if (newMedia) {
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
        }
        else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
            
        }
    }
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save failed" message:@"Failed to save image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}


// 프로필사진 터치 시에 액션 시트로 카메라 메뉴 출력
- (IBAction)callCameraAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"사진촬영", @"앨범에서 사진 선택", @"삭제", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

// 액션 시트 이벤트 핸들러
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // 사진 촬영
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
                imagePicker.allowsEditing = NO;
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];
                newMedia = YES;
            }
            break;
        case 1: // 앨범에서 선택하기
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
                picker.allowsEditing = NO;
                [self presentModalViewController:picker animated:YES];
                [picker release];
                newMedia = NO;
            }
            break;
        case 2: // 삭제하기
            [_profileImageBtn setImage:nil forState:UIControlStateNormal];
            [_profileImageBtn setImage:nil forState:UIControlStateHighlighted];
            break;
    }
}

- (void)dealloc {
    [_bikeCategoryPickerView release];
    [_bikeSelectToolbar release];
    [_selectBikeBarButton release];
    [_ageSelectButton release];
    [_regionSelectButton release];
    [_bikeSelectButton release];
    [_genderSegment release];
    [_profileImageView release];
    [_ageLabel release];
    [_regionLabel release];
    [_bikeLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBikeCategoryPickerView:nil];
    [self setBikeSelectToolbar:nil];
    [self setSelectBikeBarButton:nil];
    [self setAgeSelectButton:nil];
    [self setRegionSelectButton:nil];
    [self setBikeSelectButton:nil];
    [self setGenderSegment:nil];
    [self setProfileImageView:nil];
    [self setAgeLabel:nil];
    [self setRegionLabel:nil];
    [self setBikeLabel:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _bikePickerView) {
        [_bikeLabel setText:[NSString stringWithFormat:@"%@", [_bikeArray objectAtIndex:[_bikePickerView selectedRowInComponent:0]]]];
        NSLog(@"%@", [_bikeArray objectAtIndex:[_bikePickerView selectedRowInComponent:0]]);
    }
    else if (pickerView == _agePickerView) {
        [_ageLabel setText:[NSString stringWithFormat:@"%@", [_ageArray objectAtIndex:[_agePickerView selectedRowInComponent:0]]]];
        NSLog(@"%@", [_ageArray objectAtIndex:[_agePickerView selectedRowInComponent:0]]);
    }
    else {
        [_regionLabel setText:[NSString stringWithFormat:@"%@", [_regionArray objectAtIndex:[_regionPickerView selectedRowInComponent:0]]]];
        NSLog(@"%@", [_regionArray objectAtIndex:[_regionPickerView selectedRowInComponent:0]]);
    }
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == _bikePickerView) {
        return [_bikeArray count];
    }
    else if (pickerView == _agePickerView) {
        return [_ageArray count];
    }
	return [_regionArray count];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}
#pragma mark Picker Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *returnStr = @"";
	
	if (pickerView == _bikePickerView) {
        returnStr = [_bikeArray objectAtIndex:row];
    }
    else if (pickerView == _agePickerView) {
        return [_ageArray objectAtIndex:row];
    }
    else {
        return [_regionArray objectAtIndex:row];
    }

	return returnStr;
}



@end
