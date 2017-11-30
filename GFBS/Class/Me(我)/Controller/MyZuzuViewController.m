//
//  MyZuzuViewController.m
//  GFBS
//
//  Created by Alice Jin on 13/6/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "MyZuzuViewController.h"
#import "ZBLocalized.h"
#import "AppDelegate.h"
#import "LeaderboardHomeTableViewController.h"
#import "NotificationItem.h"
#import "ZZFriendRequestModel.h"

#import "GFWebViewController.h"
#import "GFSettingViewController.h"
#import "BadgesCollectionViewController.h"
#import "NotificationViewController.h"
#import "ZZFriendsTableViewController.h"
#import "MeHomeTableViewController.h"

#import "EventListTableViewController.h"
#import "RestaurantViewController.h" //should be favourite restaurant


#import "GFSquareItem.h"
#import "GFSquareCell.h"
#import "ZGAlertView.h"

#import <SVProgressHUD.h>
#import <MJExtension.h>
#import <AFNetworking.h>
#import "UIBarButtonItem+Badge.h"

#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MessageUI.h>

static NSString *const ID = @"ID";
static NSInteger const cols = 2;
static CGFloat  const margin = 0;

#define itemHW  (GFScreenWidth - (cols - 1) * margin ) / cols

@interface MyZuzuViewController () <UICollectionViewDataSource,UICollectionViewDelegate,MFMessageComposeViewControllerDelegate>

/*所有button内容*/
@property (strong , nonatomic)NSMutableArray<GFSquareItem *> *buttonItems;

/**collectionView*/
@property (weak ,nonatomic) UICollectionView *functionsCollectionView;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;
@property (strong , nonatomic)NSMutableArray<NotificationItem *> *myNotifications;
@property (strong , nonatomic)NSMutableArray<ZZFriendRequestModel *> *myFriendsRequests;

@property (strong , nonatomic) UIBarButtonItem *notificationBtn;

@property (assign , nonatomic) NSInteger *notificationNum;
@property (strong, nonatomic) ZGAlertView *alertView;

@end

@implementation MyZuzuViewController

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
    [self setUpNavBar];
    [self setUpCollectionItemsData];
    [self setUpFunctionsCollectionView];
    if (_notificationNum == 0) {
         [self loadFriendsRequest];
    }
    
    /*
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViews)];
    [self.view addGestureRecognizer:tap];
     */
    
}



#pragma mark - 设置底部视图
-(void)setUpFunctionsCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    //设置尺寸
    layout.itemSize = CGSizeMake(itemHW, itemHW);
    NSLog(@"itemHW %f", itemHW);
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    
    UICollectionView *functionsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.gf_width, GFScreenHeight) collectionViewLayout:layout];
    self.functionsCollectionView = functionsCollectionView;
    self.functionsCollectionView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:functionsCollectionView];
    //关闭滚动
    functionsCollectionView.scrollEnabled = NO;
    
    //设置数据源和代理
    functionsCollectionView.dataSource = self;
    functionsCollectionView.delegate = self;
    
    //注册
    [functionsCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([GFSquareCell class]) bundle:nil] forCellWithReuseIdentifier:ID];
    //[self.functionsView addSubview:functionsCollectionView];
    //NSInteger rows = (_buttonItems.count - 1) /  cols + 1;
    //self.functionsView.gf_height = rows * itemHW + cols * margin ;
    
}

#pragma mark - Setup UICollectionView Data
-(void)setUpCollectionItemsData {
    NSArray *buttonIcons = [NSArray arrayWithObjects:@"zuzu-checkin", @"zuzu-leaderboard", @"invite-friends", @"my-friends", nil];
    NSArray *buttonTitles = [NSArray arrayWithObjects: ZBLocalized(@"Check-in", nil), ZBLocalized(@"Leaderboard", nil), ZBLocalized(@"Invite Friends", nil),ZBLocalized(@"My Friends", nil), nil];
    //NSArray *buttonTitles = [NSArray arrayWithObjects:@"Check-in", @"Leaderboard", @"Invite Friends", @"My Friends", nil];
    //NSMutableArray<GFSquareItem *> *buttonItems =[[NSMutableArray<GFSquareItem *> alloc]init];
    //self.buttonItems = buttonItems;
    self.buttonItems = [[NSMutableArray<GFSquareItem *> alloc]init];
    for (int i = 0; i < buttonIcons.count; i++) {
        GFSquareItem *squareItem = [[GFSquareItem alloc]init];
        squareItem.icon = buttonIcons[i];
        squareItem.name = buttonTitles[i];
        [_buttonItems addObject:squareItem];
    }
    NSLog(@"buttonItems:%@", _buttonItems);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"_buttonItems.count = %ld", _buttonItems.count);
    return _buttonItems.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GFSquareCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    NSLog(@"indexPath.item%ld", indexPath.item);
    NSLog(@"buttonItems indexPath.item%@", self.buttonItems[indexPath.item].name);
    
    cell.item = self.buttonItems[indexPath.item];
    
    return cell;
}

- (void)setUpNavBar
{
    [self preferredStatusBarStyle];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *settingBtn = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_settings"] WithHighlighted:[UIImage imageNamed:@"ic_settings"] Target:self action:@selector(settingClicked)];
    UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
    fixedButton.width = 20;
    UIBarButtonItem *notificationBtn = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_fa-bell-o"] WithHighlighted:[UIImage imageNamed:@"ic_fa-bell-o"] Target:self action:@selector(notificationClicked)];
    self.notificationBtn = notificationBtn;
    notificationBtn.badgeValue = @"0"; // I need the number of not checked through API
    //notificationBtn.badgePadding = 0;
    //notificationBtn.badgeMinSize = 0; //I changed their default value in category
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: settingBtn, fixedButton, notificationBtn, nil]];
    
    //Title
    self.navigationItem.title = ZBLocalized(@"My Zuzu", nil);
    
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GFSquareItem *item = _buttonItems[indexPath.item];
    
    //if ([item.name isEqualToString: @"Check-in"]) {
    if (indexPath.row == 0) {
        MeHomeTableViewController *eventVC = [[MeHomeTableViewController alloc] init];
        eventVC.navigationItem.title = ZBLocalized(@"My Checkin", nil);
        [self.navigationController pushViewController:eventVC animated:YES];
    }
    //else if ([item.name isEqualToString: @"Leaderboard"]) {
    else if (indexPath.row == 1) {
        LeaderboardHomeTableViewController *leaderboardVC = [[LeaderboardHomeTableViewController alloc] init];
        leaderboardVC.view.frame = CGRectMake(0, 0, GFScreenWidth, self.view.gf_height - GFTabBarH);
        leaderboardVC.navigationItem.title = ZBLocalized(@"Leaderboard", nil);
        [self.navigationController pushViewController:leaderboardVC animated:YES];
    }
    //else if ([item.name isEqualToString: @"Invite Friends"]) {
    else if (indexPath.row == 2) {
        [self showShareView];
    }
    //else if ([item.name isEqualToString: @"My Friends"]) {
    else if (indexPath.row == 3) {
        ZZFriendsTableViewController *myFriendsVC = [[ZZFriendsTableViewController alloc] init];
        //myFriendsVC.view.frame = CGRectMake(0, 0, GFScreenWidth, self.view.gf_height - GFTabBarH);
        //myFriendsVC.navigationItem.title = @"My Friends";
        [self.navigationController pushViewController:myFriendsVC animated:YES];
    }

    //判断
    if (![item.url containsString:@"http"]) return;
    
    NSURL *url = [NSURL URLWithString:item.url];
    GFWebViewController *webVc = [[GFWebViewController alloc]init];
    [self.navigationController pushViewController:webVc animated:YES];
    
    //给Url赋值
    webVc.url = url;
    
}

- (void)showShareView {
    /*
    NSString *shareText = @"I'm having fun on ZUZU. Come and join me!";
    NSArray *itemsToShare = @[shareText];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    [self presentViewController:activityVC animated:YES completion:nil];
     */
    
    ZGAlertView *alertView = [[ZGAlertView alloc] initWithTitle: ZBLocalized(@"Invite Friends", nil) message:@"" cancelButtonTitle:nil otherButtonTitles:nil, nil];
    self.alertView = alertView;
    
    UIButton *facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    facebookButton.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1];
    [facebookButton setTitle:ZBLocalized(@"Find friends on Facebook", nil) forState:UIControlStateNormal];
    [alertView addCustomButton:facebookButton toIndex:0];
    
    UIButton *googlePlusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    googlePlusButton.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:72.0/255.0 blue:54.0/255.0 alpha:1];
    [googlePlusButton setTitle:ZBLocalized(@"Connect with Google+", nil) forState:UIControlStateNormal];
    [alertView addCustomButton:googlePlusButton toIndex:1];
    
    UIButton *smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    smsButton.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:194.0/255.0 blue:54.0/255.0 alpha:1];
    [smsButton setTitle:ZBLocalized(@"SMS Your Friends", nil) forState:UIControlStateNormal];
    [smsButton addTarget:self action:@selector(showMessageView) forControlEvents:UIControlEventTouchUpInside];
    [alertView addCustomButton:smsButton toIndex:2];
    
    UIButton *shareUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareUrlButton.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:0 alpha:1];
    [shareUrlButton setTitle:ZBLocalized(@"Share URL", nil) forState:UIControlStateNormal];
    [shareUrlButton addTarget:self action:@selector(shareURLButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [alertView addCustomButton:shareUrlButton toIndex:3];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:ZBLocalized(@"Cancel", nil) forState:UIControlStateNormal];
    //[shareUrlButton addTarget:self action:@selector(shareURLButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [alertView addCustomButton:cancelButton toIndex:4];
    
    alertView.titleColor = [UIColor whiteColor];
    alertView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] initWithObjects:facebookButton, googlePlusButton, smsButton, shareUrlButton,cancelButton, nil];
    NSArray *iconArray = [[NSArray alloc] initWithObjects:@"ic_facebook-logo",@"ic_google-plus", @"ic_sms",@"",@"",nil];
    for (int i = 0; i < buttonArray.count; i++) {
        UIButton *button = [buttonArray objectAtIndex:i];
        button.layer.cornerRadius = 5.0f;
        button.clipsToBounds = YES;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [button addSubview:imageView];
        imageView.frame = CGRectMake(15, 10, 44 - 20, 44 - 20);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:[iconArray objectAtIndex:i]];
    }

    [alertView show];
    
}

- (void)settingClicked
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:NSStringFromClass([GFSettingViewController class]) bundle:nil];
    GFSettingViewController *settingVc = [storyBoard instantiateInitialViewController];
    [self.navigationController pushViewController:settingVc animated:YES];
}

- (void)notificationClicked
{
    NotificationViewController *notificationVC = [[NotificationViewController alloc] init];
    notificationVC.delegate = self;
    notificationVC.myNotifications = self.myNotifications;
    notificationVC.myFriendsRequests = self.myFriendsRequests;
    [self.navigationController pushViewController:notificationVC animated:YES];
}

- (void)smsButtonClicked {
    NSLog(@"smsButtonClicked!");
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"sms://"]];//发短信
}

- (void)shareURLButtonClicked {
    NSLog(@"shareURLButtonClicked!");
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"mailto://"]];//发email
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*******Here is reloading data place*****/
#pragma mark - 加载新数据
-(void)loadFriendsRequest
{
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    
    NSDictionary *inData = @{@"action" : @"getFriendRequestList", @"token" : userToken};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.myFriendsRequests = [ZZFriendRequestModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        [self loadNewData];
        
        //[self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
         //[self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark - 加载新数据
-(void)loadNewData
{
    
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    
    NSDictionary *inData = @{@"action" : @"getNotificationList", @"token" : userToken, @"lang" : userLang};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.myNotifications = [NotificationItem mj_objectArrayWithKeyValuesArray:data[@"data"]];
        self.notificationBtn.badgeValue = [NSString stringWithFormat:@"%zd", self.myFriendsRequests.count + self.myNotifications.count];
        [self countNotReadNum];
        //[self.tableView reloadData];
        
        //[self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        //[self.tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];
    }];
    
}

- (void)countNotReadNum {
    NSInteger *num = 0;
    for (int i = 0; i < self.myNotifications.count; i++) {
        if (! self.myNotifications[i].isRead) {
            num ++;
        }
    }
    for (int i = 0; i < self.myFriendsRequests.count; i++) {
        if (! self.myFriendsRequests[i].isRead) {
            num ++;
        }
    }
    
    self.notificationNum = num;
    self.notificationBtn.badgeValue = [NSString stringWithFormat:@"%zd", num];
}


- (IBAction)leaderboardButtonClicked:(id)sender {
    /*
    LeaderboardViewController *leaderboardVC = [[LeaderboardViewController alloc] init];
    [self.navigationController pushViewController:leaderboardVC animated:YES];
     */
}

- (void)dismissViews {
    if ([self.alertView isFirstResponder]) {
        [self.alertView resignFirstResponder];
    }
    
}

- (void)passValue:(NSInteger *)theValue {
    NSLog(@"passValueDelegate %zd", theValue);
    self.notificationNum = theValue;
    self.notificationBtn.badgeValue = [NSString stringWithFormat:@"%zd", theValue];
}

- (void)showMessageView
{
    
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:@""];
        controller.body = @"测试发短信";
        controller.messageComposeDelegate = self;
        
        [self presentModalViewController:controller animated:YES];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}


//MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissModalViewControllerAnimated:NO];//关键的一句   不能为YES
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        default:
            break;
    }
}


- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
    
}
@end
