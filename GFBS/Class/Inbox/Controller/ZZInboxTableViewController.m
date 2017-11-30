//
//  ZZInboxTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 14/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "ZZInboxTableViewController.h"
#import "ZZInboxCell.h"
#import "ZZLeaderboardModel.h"
#import "ZZFriendModel.h"
//#import "ZZChatViewController.h"
//#import "JCHATConversationViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <JMessage/JMessage.h>
//#import <SDImageCache.h>


static NSString *const ID = @"ID";

@interface ZZInboxTableViewController () 

@property (nonatomic, strong) NSMutableArray<ZZFriendModel *> *friendList;

@end

@implementation ZZInboxTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];
    [self setupRefresh];
    [self setUpTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNeweData)];
    [self.tableView.mj_header beginRefreshing];
    
}

- (void)loadNeweData {

    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    NSDictionary *inData = [[NSDictionary alloc] init];
    inData = @{@"action" : @"getFriendList", @"token" : userToken, @"lang" : userLang};
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        NSMutableArray *rankArray = data[@"data"];
        self.friendList = [ZZFriendModel mj_objectArrayWithKeyValuesArray:rankArray];
      
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];

}

-(void)setUpTable
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ZZInboxCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    [self.tableView reloadData];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _friendList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZZInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    ZZFriendModel *friendInfo = self.friendList[indexPath.row];
    cell.friendInfo = friendInfo;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //JCHATConversationViewController *chatVC = [[JCHATConversationViewController alloc] init];
    //ZZChatViewController *chatVC = [[ZZChatViewController alloc] init];
    //chatVC.view.frame = CGRectMake(0, ZZNewNavH, self.view.gf_width, self.view.gf_height - GFTabBarH - ZZNewNavH);
    //chatVC.hidesBottomBarWhenPushed = YES;
    ZZFriendModel *thisFriend = self.friendList[indexPath.row];
    //chatVC.title = thisRank.leaderboardMember.userUserName;
    //chatVC.title = thisFriend.friendInfo.userUserName;
    //[self.navigationController pushViewController:chatVC animated:YES];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtInxPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)setUpNavBar
{
    UIBarButtonItem *newMessageButton = [UIBarButtonItem ItemWithImage:[UIImage imageNamed:@"ic_new-message"] WithHighlighted:[UIImage imageNamed:@"ic_new-message"] Target:self action:@selector(newMessageClicked)];
    [self.navigationItem setRightBarButtonItem:newMessageButton];
    
    //Title
    self.navigationItem.title = ZBLocalized(@"Inbox", nil);
    
}

- (void)newMessageClicked {
    NSLog(@"new message clicked");
}

/*
- (void)dealloc {
    [[_ref child:@"messages"] removeObserverWithHandle:_refHandle];
}
 */


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
