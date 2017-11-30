//
//  HomePostTableViewController.m
//  GFBS
//
//  Created by Alice Jin on 17/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "HomePostTableViewController.h"
#import "GFEventsCell.h"
#import "ZZContentModel.h"
//#import "ZZCommentsViewController.h"
#import "GFCommentViewController.h"
#import "RestaurantDetailViewController.h"
#import "UserProfileCheckinViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>

static NSString *const ID = @"ID";
//@class ZZContentModel;

@interface HomePostTableViewController () {
    int contentCellHeightCount;
    int deleteIndex;
    
    int currentPage;
}

/*所有帖子数据*/
@property (strong , nonatomic)NSMutableArray<ZZContentModel *> *contents;

/*所有帖子数据*/
@property (strong , nonatomic)NSMutableArray<ZZContentModel *> *selectedContents;

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@property (strong, nonatomic) NSIndexPath *recordIndexPath;

@end


@implementation HomePostTableViewController

//@synthesize receivingType;
//@synthesize userID;

#pragma mark - 消除警告
-(MyPublishContentType)type
{
    return 0;
}

/*
#pragma mark - 消除警告
-(NSString *)restaurantID
{
    return @"";
}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    contentCellHeightCount = 0;
    deleteIndex = -1;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    currentPage = 2;
    
    [self setUpTable];
    [self setupRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpTable
{
    //self.tableView.contentInset = UIEdgeInsetsMake(33, 0, GFTabBarH, 0);
    //[self.tableView setFrame:self.view.bounds];
    //NSLog(@"table width %f",self.view.gf_width);
    //self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    //self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        // 如果tableView响应了setSeparatorInset: 这个方法,我们就将tableView分割线的内边距设为0.
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        // 如果tableView响应了setLayoutMargins: 这个方法,我们就将tableView分割线的间距距设为0.
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    //self.tableView.estimatedRowHeight = 400;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([GFEventsCell class]) bundle:nil] forCellReuseIdentifier:ID];
    
    CGFloat bannerH = 60;
    if (self.type == 0) {
        UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GFScreenWidth, bannerH)];
        bannerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gold_background"]];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, bannerH - 20, bannerH - 20)];
        icon.image = [UIImage imageNamed:@"medal"];
        [bannerView addSubview:icon];
        
        UILabel *bannerLabel = [[UILabel alloc] initWithFrame:CGRectMake(bannerH, 10, GFScreenWidth - bannerH + 10, bannerH - 20)];
        bannerLabel.text = @"Prize of this month is iPhoneX !!!";
        [bannerView addSubview:bannerLabel];
        
        self.tableView.tableHeaderView = bannerView;
    }
    
    
    //[self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //GFEventsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ZZContentModel *content = _contents[indexPath.row];
    NSLog(@"content.cellHeight %f", content.cellHeight);
    return content.cellHeight;
    
    /*
    if ([content.withImage isEqual:@1]) {
        return content.cellHeight;
    } else {
        return content.cellHeight - 274.0f;
    }
     */
    /*
    contentCellHeightCount ++;
    NSLog(@"contentCellHeightCount%zd", contentCellHeightCount);
    if (content.listImage_UIImage == NULL || content.listImage_UIImage == nil) {
        NSLog(@"contentCellHeightInPostVC without Image %f", content.cellHeight - 274.0f);
        return content.cellHeight - 274.0f;
    }
     */
    //NSLog(@"contentCellHeightInPostVC %f", content.cellHeight);
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.contents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GFEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //**** set up restaurant button **//
    UIButton *restaurantButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 16, 264, 30)];
    restaurantButton.backgroundColor = [UIColor clearColor];
    [restaurantButton addTarget:self action:@selector(restaurantButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    restaurantButton.tag = indexPath.row;
    [cell.contentView addSubview:restaurantButton];
    
    UIButton *profileImageButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 4, 50, 50)];
    profileImageButton.backgroundColor = [UIColor clearColor];
    [profileImageButton addTarget:self action:@selector(profileImageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    profileImageButton.tag = indexPath.row;
    [cell.contentView addSubview:profileImageButton];
    
    if (self.type == 2) {
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(GFScreenWidth - 60, 8, 20, 20)];
        [deleteButton setImage:[UIImage imageNamed:@"ic_select_grey.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.tag = indexPath.row;
        [cell.contentView addSubview:deleteButton];
    }
    
    
    //ZZContentModel *thisContent = self.contents[indexPath.row];
    
    cell.event = self.contents[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSIndexPath *recordIndexPath = [[NSIndexPath alloc] init];
    self.recordIndexPath = recordIndexPath;
    recordIndexPath = indexPath;
    
    GFCommentViewController *commentsVC = [[GFCommentViewController alloc] init];
    commentsVC.topic = [_contents objectAtIndex:indexPath.row];
    NSLog(@" topic cell height in postList %f", self.contents[indexPath.row].cellHeightForComment);
    NSLog(@" topic cell height in postList %f", self.contents[indexPath.row].cellHeight);
    if (self.contents[indexPath.row].listImage_UIImage == NULL) {
        NSLog(@"UIImage is null");
    }
    commentsVC.view.frame = CGRectMake(0, ZZNewNavH, self.view.gf_width, self.view.gf_height - ZZNewNavH - GFTabBarH);
    commentsVC.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:commentsVC animated:YES];
   
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
     */
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 这两句的含义跟上面两句代码相同,就不做解释了
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void) restaurantButtonClicked: (UIButton *) sender {
    ZZContentModel *thisContent = _contents[sender.tag];
    RestaurantDetailViewController *restaurantVC = [[RestaurantDetailViewController alloc] init];
    restaurantVC.thisRestaurant = thisContent.listEventRestaurant;
    [self.navigationController pushViewController:restaurantVC animated:YES];
}

- (void) profileImageButtonClicked: (UIButton *) sender {
    ZZContentModel *thisContent = _contents[sender.tag];
    UserProfileCheckinViewController *userVC = [[UserProfileCheckinViewController alloc] init];
    userVC.myProfile = thisContent.listPublishUser;
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void) deleteButtonClicked: (UIButton *) sender {
    //ZZContentModel *thisContent = _contents[sender.tag];
    deleteIndex = sender.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:ZBLocalized(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    //[actionSheet addButtonWithTitle:@"Some Action"];
    [actionSheet addButtonWithTitle:ZBLocalized(@"Delete", nil)];
    //actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //**** delete function is buttonIndex == 1 *****//
    if (buttonIndex == 1) {
        ZZContentModel *thisContent = _contents[deleteIndex];
        [self.contents removeObjectAtIndex:deleteIndex];
        [self.tableView reloadData];
        
        NSLog(@"loadNewEvents工作了");
        //NSLog(@"receivingType %@",receivingType);
        //NSLog(@"userID in HomePostVC %@", userID);
        
        
        NSString *userToken = [AppDelegate APP].user.userToken;
        NSDictionary *inSubData = @{@"checkinId" : thisContent.listEventID};
        
        NSDictionary *inData = @{@"action" : @"deleteMyCheckinPost", @"token" : userToken, @"data" : inSubData};
        
        NSDictionary *parameters = @{@"data" : inData};
        
        [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
            
  
        } failed:^(NSError *error) {
            [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
            [SVProgressHUD dismiss];
        }];
        
    }
}


- (void)setupRefresh
{
    self.tableView.mj_header = [GFRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewEvents)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [GFRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

/*************************Here is reloading data place************************/
#pragma mark - 加载新数据
-(void)loadNewEvents
{
    NSLog(@"loadNewEvents工作了");
    currentPage = 2;
    
    NSString *userToken = [ZZUser shareUser].userToken;
    //NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    NSLog(@"preferred language [AppDelegate APP].user.preferredLanguage %@", userLang);
    
    NSLog(@"user token %@", userToken);
    
    NSDictionary *inSubData = @{@"page" : @1};
    
    NSDictionary *inData = [[NSDictionary alloc] init];
    if (self.type == 0) {
        inData = @{@"action" : @"getAllCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 1) {
        inData = @{@"action" : @"getFriendCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 2) {
        inData = @{@"action" : @"getMyCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 4) {
        NSDictionary *inSubData = @{@"restaurantId" : self.restaurantID};
        inData = @{@"action" : @"getRestaurantCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 5) {
        inData = @{@"action" : @"getMyCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    }
    /*
    else if ([receivingType isEqualToString:@"User checkin"]) {
        inData = @{@"action" : @"getAllCheckinList", @"token" : userToken};
        NSLog(@"getUserCheckinListworks");
    }
     */
    
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"publish content parameters %@", parameters);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.contents = [ZZContentModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        for (int i = 0; i < self.contents.count; i++) {
            if (self.contents[i].numOfLike == NULL) {
                self.contents[i].numOfLike = 0;
            }
            NSString *str = [self.contents[i].listImage.imageUrl pathExtension];
            NSLog(@"str of pathExtension %@", str);
            
            if ([str isEqualToString:@"undefined"] || str == NULL) {
                self.contents[i].withImage = @0;
            } else {
                self.contents[i].withImage = @1;
            }
        }
        
        self.selectedContents = [[NSMutableArray alloc] init];
        
        /*
         if (self.type == 5) {
         NSLog(@"select process starts working");
         for (int i = 0; i < _contents.count ; i++) {
         if ([_contents[i].listPublishUser.userID isEqualToString:self.userID]) {
         [_selectedContents addObject:_contents[i]];
         }
         }
         
         [_contents removeAllObjects];
         [_contents addObjectsFromArray:_selectedContents];
         }
         */
        
        [self passValueMethod];
        
        [self.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];

}

#pragma mark - 加载更多数据
-(void)loadMoreData
{
    NSLog(@"loadMoreData工作了");
    if (currentPage == 0) {
        [self.tableView.mj_footer endRefreshing];
        return;
    } // if no new data
    
    NSString *userToken = [AppDelegate APP].user.userToken;
    //NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    
    NSString *userLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"KEY_USER_LANG"];
    if ([userLang isEqualToString:@"zh-Hant"]) {
        userLang = @"tw";
    }
    NSLog(@"preferred language [AppDelegate APP].user.preferredLanguage %@", userLang);
    
    NSLog(@"user token %@", userToken);
    
    NSLog(@"current page %zd", currentPage);
    NSNumber *pageParameter = [[NSNumber alloc] initWithInt:currentPage];
    
    NSDictionary *inSubData = @{@"page" : pageParameter};
    
    NSDictionary *inData = [[NSDictionary alloc] init];
    if (self.type == 0) {
        inData = @{@"action" : @"getAllCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 1) {
        inData = @{@"action" : @"getFriendCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 2) {
        inData = @{@"action" : @"getMyCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 4) {
        NSDictionary *inSubData = @{@"restaurantId" : self.restaurantID};
        inData = @{@"action" : @"getRestaurantCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    } else if (self.type == 5) {
        inData = @{@"action" : @"getMyCheckinList", @"token" : userToken, @"lang" : userLang, @"data":inSubData};
    }
    
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        NSMutableArray<ZZContentModel *> *moreData = [ZZContentModel mj_objectArrayWithKeyValuesArray:data[@"data"]];
        
        if (moreData.count != 0) {
            [self.contents addObjectsFromArray:moreData];
            
            int start = (int)(self.contents.count - moreData.count);
            
            for (int i = start; i < self.contents.count; i++) {
                
                if (self.contents[i].numOfLike == NULL) {
                    self.contents[i].numOfLike = 0;
                }
                NSString *str = [self.contents[i].listImage.imageUrl pathExtension];
                NSLog(@"str of pathExtension %@", str);
                
                if ([str isEqualToString:@"undefined"] || str == NULL) {
                    self.contents[i].withImage = @0;
                } else {
                    self.contents[i].withImage = @1;
                }
            }
            currentPage ++;
        } else {
            currentPage = 0;
        }
        
        [self.tableView reloadData];
        [self.tableView.mj_footer endRefreshing];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}



- (void)passValueMethod {
    NSInteger *num = self.contents.count;
    NSLog(@"passValueMethod %zd", num);
    [_delegate passValue:num];
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




//************************* update cell which is hearted in commentVC ******************************//
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"indexPathForSlectedRow in viewWillAppear %@", [self.tableView indexPathForSelectedRow]);
    NSLog(@"indexPathForSlectedRow in viewWillAppear.row %ld", [self.tableView indexPathForSelectedRow].row);
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[self.tableView indexPathForSelectedRow],nil] withRowAnimation:UITableViewRowAnimationNone];
}


@end
