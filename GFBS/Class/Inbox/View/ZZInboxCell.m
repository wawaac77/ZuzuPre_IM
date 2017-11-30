//
//  ZZInboxCell.m
//  GFBS
//
//  Created by Alice Jin on 14/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZZInboxCell.h"
#import "ZZFriendModel.h"

#import <UIImageView+WebCache.h>

@interface ZZInboxCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ZZInboxCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFriendInfo:(ZZFriendModel *)friendInfo {
    self.usernameLabel.text = friendInfo.friendInfo.userUserName;
    
    UIImage *placeholder = [[UIImage imageNamed:@"defaultUserIcon"]gf_circleImage];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:friendInfo.friendInfo.userProfileImage.imageUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return ;
        self.profileImageView.image = [image gf_circleImage];
    }];
    
}

@end
