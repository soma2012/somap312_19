//
//  NameAndAvatarSettingViewController.m
//  rainsync
//
//  Created by 승원 김 on 12. 10. 29..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import "NameAndAvatarSettingViewController.h"
#import "CompletionSettingViewController.h"
#import "FirstSettingViewController.h"
@interface NameAndAvatarSettingViewController ()

@end

@implementation NameAndAvatarSettingViewController
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //[super initWithRootViewController:self.view];
    
    if (self) {
        // Custom initialization
        self.title = @"내 정보 설정";
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *prev = [[UIBarButtonItem alloc] initWithTitle:@"이전" style: UIBarButtonItemStyleBordered target:self action:@selector(goToPrevSetting)];
        self.navigationItem.leftBarButtonItem = prev;
        [prev release];
        
        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:@"다음" style: UIBarButtonItemStyleBordered target:self action:@selector(goToNextSetting)];
        self.navigationItem.rightBarButtonItem = next;
        [next release];
        

        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_nameTextField release];
    [_profileImageBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setNameTextField:nil];
    self.imageView = nil;
    [self setProfileImageBtn:nil];
    [super viewDidUnload];
}

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [_nameTextField resignFirstResponder];
}

- (void)goToPrevSetting {
    
    //FirstSettingViewController *firstController = [[FirstSettingViewController alloc]initWithNibName:@"FirstSettingViewController" bundle:nil];
    [self.navigationController popViewControllerAnimated:FALSE];
    
    //[[[UIApplication sharedApplication] keyWindow] setRootViewController:firstController];
    //[firstController release];
    //[self.view removeFromSuperview];
    
    
}

- (void)goToNextSetting {
    CompletionSettingViewController *completionSettingViewController = [[CompletionSettingViewController alloc] initWithNibName:@"CompletionSettingViewController" bundle:nil];
    [self.navigationController pushViewController:completionSettingViewController animated:nil];
    
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
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}


// 프로필사진 터치 시에 액션 시트로 카메라 메뉴 출력
- (IBAction)callCameraAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"사진촬영", @"앨범에서 사진 선택", @"삭제", nil];
    [actionSheet showInView:self.view];
}

// 액션 시트 이벤트 핸들러
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 사진 촬영
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            imagePicker.allowsEditing = NO;
            [self presentModalViewController:imagePicker animated:YES];
            newMedia = YES;
        }
    }
    // 앨범에서 선택하기
    else if (buttonIndex == 1) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
            picker.allowsEditing = NO;
            [self presentModalViewController:picker animated:YES];
            newMedia = NO;
        }
    }
    // 삭제하기
    else {
        [_profileImageBtn setImage:nil forState:UIControlStateNormal];
        [_profileImageBtn setImage:nil forState:UIControlStateHighlighted];
    }
}
@end
