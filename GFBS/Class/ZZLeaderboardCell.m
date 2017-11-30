//
//  ZZLeaderboardCell.m
//  GFBS
//
//  Created by Alice Jin on 13/7/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ZZLeaderboardCell.h"
#import "ZZLeaderboardModel.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>

@interface ZZLeaderboardCell ()


@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pointImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersNumLabel;


@end

@implementation ZZLeaderboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        _numberLabel.font = [UIFont boldSystemFontOfSize:18];
        _numberLabel.textColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    }
    else {
        _numberLabel.textColor = [UIColor blackColor];
    }

}

- (void)setUser:(ZZLeaderboardModel *)user {
    ZZLeaderboardModel *thisUser = user;
    _numberLabel.text = [NSString stringWithFormat:@"%@", thisUser.leaderboardRank];
    
    UIImage *placeholder = [[UIImage imageNamed:@"defaultUserIcon"]gf_circleImage];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:thisUser.leaderboardMember.userProfileImage.imageUrl] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) return ;
        //self.profileImageView.image = [image gf_circleImage];
    }];
    
    _profileImageView.layer.masksToBounds = YES;
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
    
    _usernameLabel.text = thisUser.leaderboardMember.userUserName;
    _locationLabel.text = thisUser.leaderboardMember.userLastCheckIn.listEventRestaurant.restaurantName;
    _scoreLabel.text = [NSString stringWithFormat:@"%@",thisUser.leaderboardRating];
    if (thisUser.leaderboardMember.numOfFollower != NULL) {
        _followersNumLabel.text = [NSString stringWithFormat:@"%@ followers", thisUser.leaderboardMember.numOfFollower];
    }
}

-(void) downloadImageFromURL :(NSString *)imageUrl{
    
    if (self.user.leaderboardMember.userProfileImage_UIImage != nil) {
        self.profileImageView.image = self.user.leaderboardMember.userProfileImage_UIImage;
    } else {
    
    NSURL  *url = [NSURL URLWithString:imageUrl];
    
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    NSLog(@"url %@", url);
    NSLog(@"urlData %@", urlData);
    
    if ( urlData )
        
    {
        
        NSLog(@"Downloading started...");
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"dwnld_image.png"];
        
        NSLog(@"FILE : %@",filePath);
        
        [urlData writeToFile:filePath atomically:YES];
        
        UIImage *image1=[UIImage imageWithContentsOfFile:filePath];
        self.user.leaderboardMember.userProfileImage_UIImage = image1;
        self.profileImageView.image=image1;
        
        NSLog(@"Completed...");
        
    }
    }
}


@end
