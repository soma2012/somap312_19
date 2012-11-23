//
//  ProfileEditViewController.h
//  rainsync
//
//  Created by 승원 김 on 12. 10. 31..
//  Copyright (c) 2012년 rainsync. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+AFNetworking.h"

@interface ProfileEditViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    BOOL newMedia;  // 새로운 사진인지 판단하는 불린값
    
    int pickerNumber;
}

@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIButton *profileImageBtn;
@property (retain, nonatomic) IBOutlet UIButton *ageSelectButton;
@property (retain, nonatomic) IBOutlet UILabel *ageLabel;
@property (retain, nonatomic) IBOutlet UIButton *regionSelectButton;
@property (retain, nonatomic) IBOutlet UILabel *regionLabel;
@property (retain, nonatomic) IBOutlet UIButton *bikeSelectButton;
@property (retain, nonatomic) IBOutlet UILabel *bikeLabel;


@property (retain, nonatomic) IBOutlet UISegmentedControl *genderSegment;

@property (retain, nonatomic) NSArray *bikeArray;
@property (retain, nonatomic) NSArray *ageArray;
@property (retain, nonatomic) NSArray *regionArray;

@property (nonatomic, retain) UIView *currentPicker;            // 피커뷰에 올릴 UIView
@property (retain, nonatomic) IBOutlet UIToolbar *bikeSelectToolbar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *selectBikeBarButton;

@property (retain, nonatomic) UIPickerView *agePickerView;      // 나이 피커뷰
@property (retain, nonatomic) UIPickerView *regionPickerView;   // 지역 피커뷰
@property (retain, nonatomic) UIPickerView *bikePickerView;     // 자전거 피커뷰
@property (retain, nonatomic) IBOutlet UIPickerView *bikeCategoryPickerView;

@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) NSString *profile;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *region;
@property (retain, nonatomic) NSString *bike;
@property (retain, nonatomic) NSString *gender;
@property (retain, nonatomic) NSString *age;

- (void)cancelAndBack;
- (void)saveEditProfile;

- (IBAction)textFieldDoneEditing:(id)sender;    // 키보드 감추기
- (IBAction)backgroundTap:(id)sender;           // 배경 터치시 키보드 감추기
- (IBAction)callCameraAction:(id)sender;        // 카메라 메뉴 호출

- (IBAction)selectAge:(id)sender;
- (IBAction)selectRegion:(id)sender;
- (IBAction)selectBike:(id)sender;

- (IBAction)hidePicker:(id)sender;
@end
