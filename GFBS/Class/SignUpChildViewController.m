//
//  SignUpChildViewController.m
//  GFBS
//
//  Created by Alice Jin on 26/5/2017.
//  Copyright © 2017 apple. All rights reserved.
//
#import "AppDelegate.h"
#import "SignUpChildViewController.h"

#import "JChatConstants.h"
#import "NSString+MessageInputView.h"
#import "JCHATSetDetailViewController.h"
#import "JCHATTimeOutManager.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <FirebaseAuth/FirebaseAuth.h>
//#import "MeasurementHelper.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface SignUpChildViewController () <GIDSignInUIDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signupWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *signupWithGoogleButton;
- (IBAction)googleSignupButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
- (IBAction)signupButtonClicked:(id)sender;

@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;


@end

@implementation SignUpChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    self.view.backgroundColor = [UIColor clearColor];
    [self setupLayout];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    //********google+ signin *****/
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    // Uncomment to automatically sign in the user.
    [[GIDSignIn sharedInstance] signInSilently];
   
    //**firebase**//
    self.handle = [[FIRAuth auth]
                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                       if (user) {
                           //[MeasurementHelper sendLoginEvent];
                           [self performSegueWithIdentifier:@"SignInToFP" sender:nil];
                       }
                   }];
    
     // [START_EXCLUDE silent]
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveToggleAuthUINotification:)
     name:@"ToggleAuthUINotification"
     object:nil];
    
    [self toggleAuthUI];

}

-(void)dismissKeyboard {
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_userTextField resignFirstResponder];
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupLayout {
    _signupWithFacebookButton.layer.cornerRadius = 5.0f;
    _signupWithFacebookButton.clipsToBounds = YES;
    _signupWithFacebookButton.backgroundColor = [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1];
    [_signupWithFacebookButton addTarget:self action:@selector(loginFBButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _signupWithGoogleButton.layer.cornerRadius = 5.0f;
    _signupWithGoogleButton.backgroundColor = [UIColor colorWithRed:211.0/255.0 green:72.0/255.0 blue:54.0/255.0 alpha:1];
    
    
    _signupButton.layer.cornerRadius = 5.0f;
    _signupButton.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:167.0/255.0 blue:78.0/255.0 alpha:1];
    
    _passwordTextField.secureTextEntry = YES;
    /*
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChageFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
     */
    
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];

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

- (IBAction)signupButtonClicked:(id)sender {
    
    NSString *email = _emailTextField.text;
    NSString *username = _userTextField.text;
    NSString *name = _nameTextField.text;
    NSString *password = _passwordTextField.text;
    
    if (email.length == 0|| username.length == 0 || name.length == 0 || password.length == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"Information is missing, please fill in all the blanks ^^" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
    
    else
    {
        NSDictionary *emailAndPassword = @{
                                           @"email" : email,
                                           @"password" : password,
                                           @"name": name,
                                           @"username" : username
                                           };
        NSDictionary *inData = @{
                                 @"action" : @"register",
                                 @"data" : emailAndPassword
                                 };
        NSDictionary *parameters = @{@"data" : inData};
        
        NSLog(@"upcoming events parameters %@", parameters);
        
        [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
            
            ZZUser *thisUser = [ZZUser mj_objectWithKeyValues:data[@"data"]];
            
            if (thisUser == nil) {
                [self registJMessageWithUsername:email password:password];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hi" message:@"The email is registered, please login or active the account ^^" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alertView show];
                
            } else {
                if ([thisUser.userStatus isEqualToString:@"inactive"]) {
                    [self registJMessageWithUsername:email password:password];
                   
                    /**the following else part will never be implemented for this api**/
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hi!" message:@"You have already had an account, please login ^^" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    [AppDelegate APP].user = [[ZZUser alloc] init];
                    [AppDelegate APP].user = thisUser;
                    
                }
                
            }
            
        } failed:^(NSError *error) {
            [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
            [SVProgressHUD dismiss];
        }];
    
        
        
        //********** regist Firebase ***********************//
        /*
        [[FIRAuth auth]createUserWithEmail:self.emailTextField.text password:self.passwordTextField.text completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
           
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
                
                [SVProgressHUD showWithStatus:@"Busy network, please try later"];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });

            }
            else{
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hi" message:@"Firebase registed!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }];
    */
        
    }
    
}

- (void)registJMessageWithUsername:(NSString *)username password:(NSString *)password {
    //[MBProgressHUD showMessage:@"正在注册" view:self.view];
    //[[JCHATTimeOutManager ins] startTimerWithVC:self];
    [JMSGUser registerWithUsername:username
                          password:password
                 completionHandler:^(id resultObject, NSError *error) {
                     [[JCHATTimeOutManager ins] stopTimer];
                     if (error == nil) {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [MBProgressHUD showMessage:@"注册成功" view:self.view];
                         [[JCHATTimeOutManager ins] startTimerWithVC:self];
                         [JMSGUser loginWithUsername:username
                                            password:password
                                   completionHandler:^(id resultObject, NSError *error) {
                                       [[JCHATTimeOutManager ins] stopTimer];
                                       if (error == nil) {
                                           [[NSUserDefaults standardUserDefaults] setObject:username forKey:kuserName];
                                           [[NSUserDefaults standardUserDefaults] setObject:username forKey:klastLoginUserName];
                                           
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           JCHATSetDetailViewController *detailVC = [[JCHATSetDetailViewController alloc] init];
                                           [self.navigationController pushViewController:detailVC animated:YES];
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           
                                           UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Congretulations!" message:@"You have registered a Zuzu account, please go to the email and activate it ^^" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                           [alertView show];
                                       } else {
                                           DDLogDebug(@"login fail error  %@",error);
                                           NSString *alert = [JCHATStringUtils errorAlert:error];
                                           alert = [JCHATStringUtils errorAlert:error];
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                           [MBProgressHUD showMessage:alert view:self.view];
                                           DDLogError(alert);
                                       }
                                   }];
                     } else {
                         NSString *alert = @"注册失败";
                         alert = [JCHATStringUtils errorAlert:error];
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [MBProgressHUD showMessage:alert view:self.view];
                     }
                 }];
}

- (void)JMessageUserLoginSave {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.emailTextField.text forKey:kuserName];
    [userDefaults setObject:self.passwordTextField.text forKey:kPassword];
    [userDefaults synchronize];
}

#pragma mark - 监听键盘的弹出和隐藏
/*
- (void)keyBoardWillChageFrame:(NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight + 50);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);
    
}
*/

- (void)keyBoardWillHide:(NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, - keyBoadrFrame.origin.y + GFScreenHeight);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);
}

- (void)keyBoardWillShow: (NSNotification *)note
{
    //键盘最终的Frame
    CGRect keyBoadrFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //动画
    CGFloat animKey = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animKey animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0,keyBoadrFrame.origin.y - GFScreenHeight + 50);
    }];
    NSLog(@"KeyboardFrame.origin.y %f", keyBoadrFrame.origin.y);

}
/*
#pragma mark - 键盘弹出和退出
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 先退出之前的键盘
    [self.view endEditing:YES];
    // 再叫出键盘
    [self.emailTextField becomeFirstResponder];
}
 */

#pragma -Google+ part
// [START toggle_auth]
- (void)toggleAuthUI {
    if ([GIDSignIn sharedInstance].currentUser.authentication == nil) {
        // Not signed in
        //self.statusText.text = @"Google Sign in\niOS Demo";
        //self.signInButton.hidden = NO;
        //self.signOutButton.hidden = YES;
        //self.disconnectButton.hidden = YES;
    } else {
        // Signed in
        //self.signInButton.hidden = YES;
        //self.signOutButton.hidden = NO;
        //self.disconnectButton.hidden = NO;
    }
}
// [END toggle_auth]

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSLog(@"Customer details: %@ %@ %@ %@", userId, idToken, name, email);
    // ...
}

- (void)dealloc {
    
    [[FIRAuth auth] removeAuthStateDidChangeListener:_handle];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"ToggleAuthUINotification"
     object:nil];
    
}

- (void) receiveToggleAuthUINotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"ToggleAuthUINotification"]) {
        [self toggleAuthUI];
        //self.statusText.text = notification.userInfo[@"statusText"];
    }
}


- (IBAction)googleSignupButtonClicked:(id)sender {
    //[self signIn:<#(GIDSignIn *)#> didSignInForUser:<#(GIDGoogleUser *)#> withError:nil];
}

//************************ end of google signin *******************************//

//************************login with Facebook *******************************//
- (void)loginFBButtonClicked {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             NSLog(@"facebookToken %@", result.token);
             
         }
     }];
}
//************************* end of Facebook signin part **************************//
@end
