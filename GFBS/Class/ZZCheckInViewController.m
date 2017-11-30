//
//  ZZCheckInViewController.m
//  GFBS
//
//  Created by Alice Jin on 13/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "ZZCheckInViewController.h"
#import "DPSharePopView.h"
//#import "DropDownListView.h"
//#import "GFAddToolBar.h"
#import "GFPlaceholderTextView.h"
//#import "AddLLImagePickerVC.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@class EventRestaurant;

@interface ZZCheckInViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSMutableArray *chooseArray;
    NSNumber *selectedInteger;
    
    float longitude;
    float latitude;
    
    float margin;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *topProfileImageView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *checkinLabel;
- (IBAction)locationButtonClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) UIView *toolBarView;

//@property (weak, nonatomic) IBOutlet UIButton *imagePickerButton;
@property (strong, nonatomic) UIButton *imagePickerButton;
- (IBAction)imagePickerButtonClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) UIButton *cancelButton;
- (IBAction)cancelButtonClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@property (strong, nonatomic) UIButton *checkinButton;
- (IBAction)checkinButtonClicked:(id)sender;

//@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) UIButton *facebookButton;
- (IBAction)facebookButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
- (IBAction)twitterButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *pickerImageView;

@property (nonatomic, weak) UIImageView *imageView;

@property (weak, nonatomic) UIImage *pickedImage;

/** 文本输入控件 */
@property (nonatomic, weak) GFPlaceholderTextView *textView;
//@property (nonatomic, weak) GFAddToolBar *toolBar;

@property (strong, nonatomic) NSMutableArray *locationArray;
@property (strong, nonatomic) NSMutableArray *restaurantIconArray;

@property (strong, nonatomic) GFHTTPSessionManager *manager;
@property (strong , nonatomic)NSMutableArray<EventRestaurant *> *restaurants;

@end

@implementation ZZCheckInViewController 

#pragma mark - 懒加载
-(GFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [GFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    [self setUpPostView];
    // Do any additional setup after loading the view from its nib.
}

- (void)setUpPostView {
    [self setUpBase];
    [self setUpTextView];
    [self setUpToolBarView];
    [self setUpImageView];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpNavBar];
}

- (void)setUpNavBar {
    [self preferredStatusBarStyle];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setUpTopView];
    
    NSString *str = ZBLocalized(@"Please select your check-in location", nil);
    _locationButton.titleLabel.text = [NSString stringWithFormat:@"        %@", str];
    
    _checkinLabel.text = ZBLocalized(@"Check-in", nil);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"开始定位:%@",newLocation);
    [manager stopUpdatingHeading];
    //if (self.data == nil) {
    longitude = newLocation.coordinate.longitude;
    latitude =  newLocation.coordinate.latitude;
    [self loadNewData];
    NSLog(@"longtitude %f", longitude);
    NSLog(@"latitude %f", latitude);
    //}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位错误");
}

- (void)setUpTopView {
    _topProfileImageView.layer.cornerRadius = _topProfileImageView.frame.size.width / 2;
    _topProfileImageView.clipsToBounds = YES;
    //_topProfileImageView.image = [UIImage imageNamed:@"profile_image_animals.jpeg"];
    NSString *imageURL = [[NSString alloc] init];
    imageURL = [AppDelegate APP].user.userProfileImage.imageUrl;
    
    [self.topProfileImageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return ;
        self.topProfileImageView.image = [image gf_circleImage];
    }];
    
    _locationButton.layer.borderWidth = 1.0f;
    _locationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _locationButton.layer.cornerRadius = 4.0f;
    _locationButton.clipsToBounds = YES;
    
   
}

//*************** load locations from api *****************//
- (void)loadNewData {
    
    NSArray *geoPoint = [[NSArray alloc] init];
    //if (longitude) {
        NSNumber *longtitudeNS = [NSNumber numberWithFloat:longitude];
        NSNumber *latitudeNS = [NSNumber numberWithFloat:latitude];
        geoPoint = [[NSArray alloc] initWithObjects:longtitudeNS, latitudeNS, nil];
        NSLog(@"longtitudeNS & latitudeNS %@,  %@", longtitudeNS, latitudeNS);
    //} else {
     //   geoPoint = @[@114, @22];
    //}
    
    NSDictionary *keyFactors = @
    {
        @"keyword" : @"",
        @"address" : @"",
        @"maxPrice" : @"",
        @"minPrice" : @"",
        @"landmark" : @"",
        @"district" : @"",
        @"cuisine" : @"",
        @"page" : @"",
        @"geoPoint" : geoPoint
    };
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = @{
                             @"action" : @"searchRestaurant",
                             @"lang" : userLang,
                             @"data" : keyFactors
                             };
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"search Restaurant %@", parameters);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        NSArray *restaurantsArray = data[@"data"];
        
        self.restaurants = [EventRestaurant mj_objectArrayWithKeyValuesArray:restaurantsArray];
        self.locationArray = [[NSMutableArray alloc] init];
        self.restaurantIconArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < _restaurants.count; i++) {
            [_locationArray addObject:_restaurants[i].restaurantName];
            [_restaurantIconArray addObject:_restaurants[i].restaurantIcon.imageUrl];
        }
        NSLog(@"_locationArray %@", _locationArray);
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

//*************** select checkin location *****************//
- (IBAction)locationButtonClicked:(id)sender {
    
    UIButton *btn=sender;
    DPSharePopView *view=[DPSharePopView initWithSuperView:btn menuCellNameArray:_locationArray imageNameArray:_restaurantIconArray cellDidClickBlock:^(NSInteger index) {
        
        NSLog(@"cellDidClickBlock %ld", index);
        NSNumber *selected = [[NSNumber alloc] initWithInteger:index];
        
        NSLog(@"self.selectedIndex = %zd", selected);
        selectedInteger = selected;
        _locationButton.titleLabel.text = [NSString stringWithFormat:@"        %@",_locationArray[index]];
    }];
    
    [view show];
    
    
    /*
    chooseArray = [NSMutableArray arrayWithArray:@[@[@"超清",@"高清",@"标清",@"省流",@"自动"]]];
    
    //这个dropDownView是下拉菜单的点击视图  点击该视图可以显示下拉菜单
    DropDownListView * dropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(200,200, 60, 20) dataSource:self delegate:self];
    
    
    //因为不清楚显示下拉菜单的frame 但是我们可以借助一个视图将下拉菜单视图加载到我们想要放置的位置的视图上
    UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(200, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:superView];
    self.view.backgroundColor = [UIColor whiteColor];
    //下拉菜单添加到superView的frame上
    
    dropDownView.mSuperView = superView;
    
    [self.view addSubview:dropDownView];
     */
}

/*
#pragma mark -- dropDownListDelegate
//码率切换请求方法
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    NSLog(@"童大爷选了section:%ld ,index:%ld",section,index);
    if (index == 0) {
        NSLog(@"切换超清");
    }
    if (index == 1) {
        NSLog(@"切换高清");
    }
    if (index == 2) {
        NSLog(@"切换标清");
    }
    if (index == 3) {
        NSLog(@"切换省流");
    }
    if (index == 4) {
        NSLog(@"切换自动");
    }
    _locationButton.titleLabel.text = chooseArray[section][index];
}


#pragma mark -- dropdownList DataSource
-(NSInteger)numberOfSections
{
    return [chooseArray count];
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSArray *arry =chooseArray[section];
    return [arry count];
}
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
{
    return chooseArray[section][index];
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}
*/


#pragma -tool bar
- (void)setUpToolBarView {
    
    margin = 10.0f;
    
    self.toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, GFScreenHeight - GFTabBarH - 80, GFScreenWidth, 80)];
    //self.toolBarView.frame = CGRectMake(0, GFScreenHeight - GFTabBarH - 80, GFScreenWidth, 80);
    [self.view addSubview:self.toolBarView];
    
    float buttonWidth = 20;
    
    //buttons
    self.imagePickerButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, 10, buttonWidth, buttonWidth)];
    [_imagePickerButton setImage:[UIImage imageNamed:@"ic_checkin-camera"] forState:UIControlStateNormal];
    [_imagePickerButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_imagePickerButton addTarget:self action:@selector(imagePickerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:_imagePickerButton];
    

    [_twitterButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_facebookButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
   
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, 40, (GFScreenWidth - margin * 3) /2, 30)];
    _cancelButton.layer.cornerRadius = 4.0f;
    _cancelButton.clipsToBounds = YES;
    //_cancelButton.frame = CGRectMake(margin, 0, GFScreenWidth - margin * 3, 30);
    [_cancelButton setTitle:ZBLocalized(@"Cancel", nil) forState:UIControlStateNormal];
    _cancelButton.backgroundColor = [UIColor grayColor];
    [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.toolBarView addSubview:self.cancelButton];
    
    self.checkinButton = [[UIButton alloc] initWithFrame:CGRectMake(GFScreenWidth/2 + margin/2, 40, (GFScreenWidth - 3 * margin) / 2, 30)];
    _checkinButton.layer.cornerRadius = 4.0f;
    _checkinButton.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    _checkinButton.clipsToBounds = YES;
    //_checkinButton.frame = CGRectMake(GFScreenWidth/2 + margin/2, 0, GFScreenWidth - 3 * margin, 30);
    [_checkinButton addTarget:self action:@selector(checkinButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_checkinButton setTitle:ZBLocalized(@"Check in", nil) forState:UIControlStateNormal];
    _checkinButton.backgroundColor = ZZGoldColor;
    [self.toolBarView addSubview:self.checkinButton];
    
    //self.cancelButton.frame = CGRectMake(5, GFScreenHeight - GFTabBarH - 50, 180, 30);
    //通知
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


- (void)setUpImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, GFScreenHeight - GFTabBarH - 80 - 274, GFScreenWidth, 274)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView = imageView;
    [self.view addSubview:imageView];
}

/*
- (void)setUpToolBar
{
    GFAddToolBar *toolBar = [GFAddToolBar gf_toolbar];
    self.toolBar = toolBar;
    [self.view addSubview:toolBar];
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
 */


#pragma mark - 准确布局
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    //_toolBar.gf_width = self.view.gf_width;
    //_toolBar.gf_y = GFScreenHeight - _toolBar.gf_height - ZZNewNavH;
    
}

//*************** setup textField *****************//
- (void)setUpTextView
{
    NSString *username = [AppDelegate APP].user.userUserName;
    GFPlaceholderTextView *textView = [[GFPlaceholderTextView alloc] init];
    NSString *str = ZBLocalized(@"What's in your mind", nil);
    textView.placeholder = [NSString stringWithFormat:@"%@, %@?", str, username];
    textView.frame = CGRectMake(0, ZZNewNavH, GFScreenWidth, GFScreenHeight - ZZNewNavH - GFTabBarH - 80);
    //textView.backgroundColor = [UIColor yellowColor];
    textView.delegate = self;
    [self.view addSubview:textView];
    self.textView = textView;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setUpBase
{
    self.view.backgroundColor = [UIColor whiteColor];
}

/**
 退出当前界面
 */
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 点击发表
 */
- (void)post
{
    GFBSLog(@"点击发表");
}

#pragma mark - 监听文字改变
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    //发表点击判断
    self.navigationItem.rightBarButtonItem.enabled = textView.hasText;
}

/*
#pragma mark - 键盘弹出和退出
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 先退出之前的键盘
    [self.view endEditing:YES];
    // 再叫出键盘
    [self.textView becomeFirstResponder];
}
 */

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}


#pragma - imagePicker action
//*************** imagePicker *****************//
/*
- (IBAction)imagePickerButtonClicked:(id)sender {
    
    /*
    AddLLImagePickerVC *imagePickerVC = [[AddLLImagePickerVC alloc] init];
    //imagePickerVC.view.frame = [UIScreen mainScreen].bounds;
    
    [self.navigationController pushViewController:imagePickerVC animated:YES];
    NSLog(@" %@", imagePickerVC.pickedImageArray);
    _pickedImagesArray = imagePickerVC.pickedImageArray;
     */
    /*
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}
*/


- (void)imagePickerButtonClicked {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = chosenImage;
    
    self.pickedImage = chosenImage;
    NSLog(@"chosenImage %@", chosenImage);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

//*************** cancel button *****************//
/*
- (IBAction)cancelButtonClicked:(id)sender {
    NSLog(@"Cancel Button clicked");
    self.textView.text = nil;
    self.imageView.image = nil;
    self.pickedImage = nil;
}
 */

- (void)cancelButtonClicked {
    NSLog(@"Cancel Button clicked");
    self.textView.text = nil;
    self.imageView.image = nil;
    self.pickedImage = nil;
}

- (IBAction)twitterButtonClicked:(id)sender {
}

- (IBAction)facebookButtonClicked:(id)sender {
}


//*************** checkin button *****************//
/*
- (IBAction)checkinButtonClicked:(id)sender {
    NSLog(@"check in button clicked");
    /*
    if (_pickedImage == nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"ZUZU" message:@"Please select a image from your album ^^" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else {
     */
/*
        NSLog(@"Check in posted");
        [self postCheckIn];
        self.textView.text = nil;
    self.imageView.image = nil;
    //}
    
    // if (![self.textView.text isEqualToString:@""])
}
*/

- (void)checkinButtonClicked {
    NSLog(@"check in button clicked");
   
    NSLog(@"Check in posted");
    [self postCheckIn];
    self.textView.text = nil;
    self.imageView.image = nil;
}


//*************** post checkin *****************//
- (void)postCheckIn {
    
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    NSLog(@"userToken in checkinVC %@", userToken);
    
    //NSString *restaurantId = @"58d7fd7f75fe8a7b025fe7ff";
    NSString *restaurantId = _restaurants[[selectedInteger intValue]].restaurantId;
    
    NSString *imageBase64 = [UIImagePNGRepresentation(_pickedImage)
     base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSData *imageData = UIImagePNGRepresentation(_pickedImage);
    NSString *imageType = [self contentTypeForImageData:imageData];
    NSString *imageInfo = [NSString stringWithFormat:@"data:%@;base64,%@",imageType, imageBase64];
      
    NSDictionary *inSubData = @{@"restaurantId" : restaurantId,
                                @"message" : self.textView.text,
                                @"image": imageInfo}; //what of image?
    
    NSDictionary *inData = @{@"action" : @"checkin",
                             @"token" : userToken,
                             @"data" : inSubData};
    
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.imageView.image = nil;
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"ZUZU" message:@"Check in successful!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
            break;
        case 0x42:
            return @"image/bmp";
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

#pragma mark - 监听键盘的弹出和隐藏
//*************** keyboard *****************//
- (void)keyBoardWillChageFrame:(NSNotification *)note
{
    NSLog(@"keyboard changed");
    
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        NSLog(@"toolBarView.y before %f", self.toolBarView.gf_y);
        NSLog(@"checkin button before %f", self.checkinButton.gf_y);
        NSLog(@"keyboardframe before %f", keyBoadrFrame.origin.y);
        self.toolBarView.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight);
        //self.cancelButton.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight);
        //self.checkinButton.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight);
        NSLog(@"toolBarView.y after %f", self.toolBarView.gf_y);
        NSLog(@"checkin button after %f", self.checkinButton.gf_y);
        NSLog(@"keyboardframe after %f", keyBoadrFrame.origin.y);
    }];
    
}


@end
