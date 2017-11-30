//
//  ZZAddFriendsCell.m
//  GFBS
//
//  Created by Alice Jin on 24/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZZAddFriendsCell.h"
#import "ZZFriendModel.h"
#import "ZBLocalized.h"

#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface ZZAddFriendsCell()

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@property (strong, nonatomic) ZZUser *friend;
@property (strong, nonatomic) GFHTTPSessionManager *manager;

@end



@implementation ZZAddFriendsCell

#pragma mark - 懒加载
-(GFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [GFHTTPSessionManager manager];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _manager;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMyFriend:(ZZUser *)myFriend {

    ZZUser *friend = myFriend;
    self.friend = friend;
    
    self.mainImageView.layer.cornerRadius = _mainImageView.frame.size.width / 2;
    _mainImageView.clipsToBounds = YES;
    
    UIImage *placeholder = [[UIImage imageNamed:@"defaultUserIcon"]gf_circleImage];
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:friend.userProfileImage.imageUrl] placeholderImage:placeholder];
    self.nameLabel.text = friend.userUserName;
    
    //NSString *memberId = myFriend.userID;
    [_addFriendButton addTarget:self action:@selector(addFriendButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addFriendButtonClicked {
   
    NSString *userToken = [[NSString alloc] init];
    userToken = [AppDelegate APP].user.userToken;
   
    NSString *memberId = self.friend.userID;
    NSLog(@"self.friend %@", self.friend);
    NSLog(@"memberId %@", memberId);
    
    NSDictionary *inSubData = @{@"memberId" : memberId};
    
    NSDictionary *inData = @{@"action" : @"addFriend",
                             @"token" : userToken,
                             @"data" : inSubData};
    
    NSDictionary *parameters = @{@"data" : inData};
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        self.imageView.image = nil;
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:ZBLocalized(@"Your following is successful!", nil)  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

@end
