//
//  ForgetPasswordViewController.m
//  GFBS
//
//  Created by Alice Jin on 4/9/2017.
//  Copyright © 2017 apple. All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "ResetPWSuccessViewController.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>

@interface ForgetPasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resetPWLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpView {
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_login_page"]];
    backgroundImageView.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:backgroundImageView atIndex:0];
    
    self.submitButton.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    self.submitButton.layer.cornerRadius = 4.0f;
    self.submitButton.clipsToBounds = YES;
    
    self.resetPWLabel.textColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    
}

- (IBAction)submitButtonClicked:(id)sender {
    
    NSString *email = _emailField.text;
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
            
            NSLog(@"start push resetPW success vc");
            ResetPWSuccessViewController *resetVC = [[ResetPWSuccessViewController alloc] init];
            resetVC.view.frame = [UIScreen mainScreen].bounds;
            resetVC.email = email;
            
            
            [self presentViewController:resetVC animated:YES completion:nil];
            
        } else {
            NSLog(@"Sorry The account does not exist.");
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The account does not exist." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
    NSLog(@"api connect finished");
    
}
- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
