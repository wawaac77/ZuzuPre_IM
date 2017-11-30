//
//  ZZAddFriendsViewController.m
//  GFBS
//
//  Created by Alice Jin on 24/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "ZZAddFriendsViewController.h"
#import "ZZAddFriendsCell.h"
#import "ZZFriendModel.h"
#import "ZZUser.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>

static NSString *const ID = @"ID";

@interface ZZAddFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)searchButtonClicked:(id)sender;


@property (weak ,nonatomic) GFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableArray<ZZUser *> *friendsArray;

@end

@implementation ZZAddFriendsViewController

#pragma mark - 懒加载
-(GFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [GFHTTPSessionManager manager];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchTextField.delegate = self;
    self.searchTextField.placeholder = ZBLocalized(@"Enter keyword", nil);
    [self setUpTableView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpNavBar];
}

- (void)setUpNavBar {
    
    [self preferredStatusBarStyle];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.navigationItem.title = ZBLocalized(@"Add Followings", nil);
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadNewData {
    
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    
    NSString *keyword = _searchTextField.text;
    NSLog(@"keyword %@", keyword);
    
    NSDictionary *inSubData = @{@"keyword" : keyword};
    
    NSDictionary *inData = @{@"action" : @"searchMember",
                             @"token" : userToken,
                             @"data" : inSubData};
    
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
       
        self.friendsArray = [ZZUser mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        [self.tableView reloadData];
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];

}
-(void)setUpTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZZAddFriendsCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = GFBgColor;
    
    self.tableView.rowHeight = 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZZAddFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.myFriend = _friendsArray[indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchButtonClicked:(id)sender {
    NSLog(@"searchButton clicked");
    [self loadNewData];
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchButtonClicked:nil];
    return YES;
}


@end
