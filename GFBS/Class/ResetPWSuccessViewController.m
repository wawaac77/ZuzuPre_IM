//
//  ResetPWSuccessViewController.m
//  GFBS
//
//  Created by Alice Jin on 4/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ResetPWSuccessViewController.h"
#import "LoginViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>

@interface ResetPWSuccessViewController ()
- (IBAction)resentButtonClicked:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *resetPWLabel;

@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation ResetPWSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_login_page"]];
    backgroundImageView.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    self.resetPWLabel.textColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    
}

- (IBAction)resentButtonClicked:(id)sender {
   
    NSString *email = self.email;
    NSDictionary *emailDic = @ {@"email" : email};
    NSDictionary *inData = @{
                             @"action" : @"forgetPassword",
                             @"data" : emailDic};
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"upcoming events parameters %@", parameters);
    
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        NSNumber *responseStatus = [[NSNumber alloc] init];
        responseStatus = data[@"status"];
        
        NSLog(@"responseStatus %@", responseStatus);
        if ([responseStatus isEqualToNumber:@1]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"ZUZU" message:@"You could check your email and set new password now ^^" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The account does not exist." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

- (IBAction)loginButtonClicked:(id)sender {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = [[LoginViewController alloc]init];
    [window makeKeyWindow];
}
@end
