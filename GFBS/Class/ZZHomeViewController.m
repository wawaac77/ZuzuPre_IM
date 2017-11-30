//
//  ZZHomeViewController.m
//  GFBS
//
//  Created by Alice Jin on 12/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "ZZHomeViewController.h"
#import "AllHomeTableViewController.h"
#import "FriendsHomeTableViewController.h"
#import "MeHomeTableViewController.h"
#import "LeaderboardHomeTableViewController.h"
#import "ZZAddFriendsViewController.h"
#import "LoginViewController.h"
#import "ZZUser.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

@interface ZZHomeViewController () <UIScrollViewDelegate>

/*UIScrollView*/
@property (weak ,nonatomic) UIScrollView *scrollView;

@property (weak ,nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) GFHTTPSessionManager *manager;
@property (strong, nonatomic) ZZUser *myProfile;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *topProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *topUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *topScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendsButton;
@property (weak, nonatomic) IBOutlet UILabel *topLocationLabel;
- (IBAction)addFriendsButtonClicked:(id)sender;

@end

@implementation ZZHomeViewController

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
    //[self setUpNavBar];
    [self setUpTitleView];
    [self setUpChildViewControllers];
    [self setUpScrollView];
    //添加默认自控制器View
    [self addChildViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpNavBar];
    [self loadNeweData];
    //[self setUpTopView];
}

- (void)setUpNavBar {
    
    [self preferredStatusBarStyle];
    
    // 1. hide the existing nav bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 2. create a new nav bar and style it
    //UINavigationBar *newNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 20)];
    //[newNavBar setTintColor:[UIColor whiteColor]];
    
    /*
    // 3. add a new navigation item w/title to the new nav bar
    UINavigationItem *newItem = [[UINavigationItem alloc] init];
    newItem.title = @"Paths";
    [newNavBar setItems:@[newItem]];
    
    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
    profileImageView.clipsToBounds = YES;
    profileImageView.image = [UIImage imageNamed:@"icon.png"];
    
    UINavigationItem *profileItem = [[UINavigationItem alloc] init];
    
    //UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithCustomView:profileImageView];

    [newNavBar setItems:@[profileItem]];
    */
    
    // 4. add the nav bar to the main view
    //[self.view addSubview:newNavBar];
    
}

- (void)setUpTopView {
    _topProfileImageView.layer.cornerRadius = _topProfileImageView.frame.size.width / 2;
    _topProfileImageView.clipsToBounds = YES;
        
    [self.topProfileImageView sd_setImageWithURL:[NSURL URLWithString:self.myProfile.userProfileImage.imageUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return ;
        self.topProfileImageView.image = [image gf_circleImage];
    }];

    
    _topUserLabel.text = _myProfile.userUserName;
    _topScoreLabel.text = [NSString stringWithFormat:@"%@", _myProfile.checkinPoint];
    _topLocationLabel.text = _myProfile.userLastCheckIn.listEventRestaurant.restaurantName;
    NSLog(@"listEventRestaurant.restaurantName  %@",_myProfile.userLastCheckIn.listEventRestaurant.restaurantName);
}

- (void)loadNeweData {

    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    NSLog(@"first userToken %@", userToken);
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    userLang = @"en";
    NSLog(@"userLang in homepage loadNewData %@", userLang);
    NSDictionary *inData = [[NSDictionary alloc] init];
    inData = @{@"action" : @"getMyProfile", @"token" : userToken, @"lang": userLang};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        ZZUser *thisUser = [[ZZUser alloc] init];
        NSNumber *responseStatus = [[NSNumber alloc] init];
        responseStatus = data[@"status"];
        
        NSLog(@"responseStatus %@", responseStatus);
        
        if ([responseStatus isEqualToNumber:@0]) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = [[LoginViewController alloc]init];
            [AppDelegate APP].user = nil;
            NSLog(@"status is equal to 0");
            [window makeKeyAndVisible];
            
        } else {
            thisUser = [ZZUser mj_objectWithKeyValues:data[@"data"]];
            self.myProfile = thisUser;
            [AppDelegate APP].user = thisUser;
            [self setUpTopView];
            
            //*************** user instance *********//
            
            [ZZUser shareUser].userProfileImage = thisUser.userProfileImage;
            
            [ZZUser shareUser].userID = thisUser.userID;
            [ZZUser shareUser].userUpdatedAt = thisUser.userUpdatedAt;
            [ZZUser shareUser].userCreatedAt = thisUser.userCreatedAt;
            [ZZUser shareUser].usertName = thisUser.usertName;
            [ZZUser shareUser].userEmail = thisUser.userEmail;
            //[ZZUser shareUser].usertPassword = thisUser.usertPassword;
            [ZZUser shareUser].userUserName = thisUser.userUserName;
            [ZZUser shareUser].userStatus = thisUser.userStatus;
            [ZZUser shareUser].userToken = thisUser.userToken;
            [ZZUser shareUser].userFacebookID = thisUser.userFacebookID;
            [ZZUser shareUser].userGoogleID = thisUser.userGoogleID;
            [ZZUser shareUser].userOrganizingExp = thisUser.userOrganizingExp;
            [ZZUser shareUser].userOrganizingLevel = thisUser.userOrganizingLevel;
            [ZZUser shareUser].socialExp = thisUser.socialExp;
            [ZZUser shareUser].socialLevel = thisUser.socialLevel;
            [ZZUser shareUser].checkinPoint = thisUser.checkinPoint;
            [ZZUser shareUser].userInterests = [[NSMutableArray alloc] init];
            [ZZUser shareUser].userInterests = thisUser.userInterests;
            [ZZUser shareUser].userLastCheckIn = thisUser.userLastCheckIn;
            [ZZUser shareUser].age = thisUser.age;
            [ZZUser shareUser].gender = thisUser.gender;
            [ZZUser shareUser].userIndustry = thisUser.userIndustry;
            [ZZUser shareUser].userProfession = thisUser.userProfession;
            [ZZUser shareUser].phone = thisUser.phone;
            [ZZUser shareUser].maxPrice = thisUser.maxPrice;
            [ZZUser shareUser].minPrice = thisUser.minPrice;
            [ZZUser shareUser].preferredLanguage = thisUser.preferredLanguage;
            [ZZUser shareUser].numOfFollower = thisUser.numOfFollower;
            [ZZUser shareUser].showOnLockScreen = thisUser.showOnLockScreen;
            [ZZUser shareUser].sounds = thisUser.sounds;
            [ZZUser shareUser].emailNotification = thisUser.emailNotification;
            [ZZUser shareUser].allowNotification = thisUser.allowNotification;
            [ZZUser shareUser].canSeeMyProfile = thisUser.canSeeMyProfile;
            [ZZUser shareUser].canMessageMe = thisUser.canMessageMe;
            [ZZUser shareUser].canMyFriendSeeMyEmail = thisUser.canMyFriendSeeMyEmail;
            [ZZUser shareUser].notificationNum = thisUser.notificationNum;
            NSLog(@"this user %@", thisUser);
            NSLog(@"this user.userUserName %@", thisUser.userUserName);
            NSLog(@"this User.userProfileImage.imageUrl %@", thisUser.userProfileImage.imageUrl);
            
            NSLog(@"this user. sounds %@", thisUser.sounds);
            NSLog(@"this user. emailNotification %@", thisUser.emailNotification);
            NSLog(@"this user. showonLockScreen %@", thisUser.showOnLockScreen);
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
}


- (void)setUpTitleView {
    
    NSArray *itemArray = [[NSArray alloc] init];
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    itemArray = [NSArray arrayWithObjects: ZBLocalized(@"All", nil), ZBLocalized(@"Following", nil), ZBLocalized(@"Me", nil), ZBLocalized(@"Leaderboard", nil), nil];

    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.segmentedControl = segmentedControl;
    segmentedControl.frame = CGRectMake(10, 5 + ZZNewNavH, GFScreenWidth - 20, 25);
    segmentedControl.tintColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    UIFont *font = [UIFont boldSystemFontOfSize:13.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    segmentedControl.selectedSegmentIndex = 0;//默认选中的按钮索引
    
    [segmentedControl addTarget:self action:@selector(segmentControlAction:) forControlEvents: UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
}

- (void)segmentControlAction : (UISegmentedControl *) segment {
    
    if (self.segmentedControl.selectedSegmentIndex == segment.selectedSegmentIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ZZSegmentTitleDidRepeatShowClickNotificationCenter" object:nil];
    }
    
    //让uiscrollView 滚动
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = self.scrollView.gf_width * segment.selectedSegmentIndex;
    [self.scrollView setContentOffset:offset animated:YES];
    
}

-(void)setUpChildViewControllers
{
    //All
    AllHomeTableViewController *allVC = [[AllHomeTableViewController alloc] init];
    [self addChildViewController:allVC];
    
    //Friends
    FriendsHomeTableViewController *friendsVC = [[FriendsHomeTableViewController alloc] init];
    [self addChildViewController:friendsVC];
    
    //Me
    MeHomeTableViewController *meVC = [[MeHomeTableViewController alloc] init];
    [self addChildViewController:meVC];
    
    //Leaderboard
    LeaderboardHomeTableViewController *leaderboardVC = [[LeaderboardHomeTableViewController alloc] init];
    [self addChildViewController:leaderboardVC];

}

/**
 添加scrollView
 */
-(void)setUpScrollView
{
    //不允许自动调整scrollView的内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    
    scrollView.delegate = self;
    scrollView.frame = CGRectMake(0, 35 + ZZNewNavH, self.view.gf_width, self.view.gf_height - 35 - GFTabBarH - ZZNewNavH);
    NSLog(@"self.view.gf_width in first claim scrollView is %f", self.view.gf_width);
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    scrollView.contentSize = CGSizeMake(self.view.gf_width * self.childViewControllers.count, 0);
}

#pragma mark - 添加子控制器View
-(void)addChildViewController
{
    //在这里面添加自控制器的View
    NSInteger index = self.scrollView.contentOffset.x / self.scrollView.gf_width;
    //取出自控制器
    UIViewController *childVc = self.childViewControllers[index];
    
    if (childVc.view.superview) return; //判断添加就不用再添加了
    childVc.view.frame = CGRectMake(index * self.scrollView.gf_width, 0, self.scrollView.gf_width, self.scrollView.gf_height);
    NSLog(@"index is %ld", (long) index);
    [self.scrollView addSubview:childVc.view];
    
}

#pragma mark - <UIScrollViewDelegate>

/**
 点击动画后停止调用
 */
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self addChildViewController];
}


/**
 人气拖动的时候，滚动动画结束时调用
 */
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //点击对应的按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.gf_width;
    UISegmentedControl *segmentControl = self.segmentedControl;
    segmentControl.selectedSegmentIndex = index;
    [self segmentControlAction:segmentControl];
    
    [self addChildViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addFriendsButtonClicked:(id)sender {
    ZZAddFriendsViewController *addFriendsVC = [[ZZAddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addFriendsVC animated:YES];
}
@end
