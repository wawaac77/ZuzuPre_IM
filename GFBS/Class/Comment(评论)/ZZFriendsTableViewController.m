//
//  ZZFriendsTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 18/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "ZZFriendsTableViewController.h"
#import "ZZFriendModel.h"
#import "ZZFriendCell.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

static NSString *const ID = @"ID";

@interface ZZFriendsTableViewController ()

/*所有帖子数据*/
@property (strong , nonatomic)NSMutableArray<ZZFriendModel *> *friendsArray;
/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation ZZFriendsTableViewController

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
    
    [self setUpTable];
    [self setupRefresh];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setUpNavBar];
}

- (void)setUpNavBar {
    
    [self preferredStatusBarStyle];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.title = ZBLocalized(@"My Friends", nil);
    
    UIBarButtonItem *addButton = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_settings"] WithHighlighted:[UIImage imageNamed:@"ic_settings"] Target:self action:@selector(settingClicked)];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUpTable
{
    NSLog(@"table width %f",self.view.gf_width);
    self.tableView.separatorStyle = UITableViewStylePlain;
    [self.tableView setFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZZFriendCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZZFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    ZZFriendModel *myFriend = self.friendsArray [indexPath.row];
    
    cell.myFriend = myFriend;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}


- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewEvents)];
    [self.tableView.mj_header beginRefreshing];
    
    //self.tableView.mj_footer = [GFRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

/*******Here is reloading data place*****/
#pragma mark - 加载新数据
-(void)loadNewEvents
{
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    NSDictionary *inData = @{@"action" : @"getFriendList", @"token" : userToken};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.friendsArray = [ZZFriendModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //清理缓存 放在这个个方法中调用频率过快
    [[SDImageCache sharedImageCache] clearMemory];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}


@end
