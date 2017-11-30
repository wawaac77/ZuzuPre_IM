//
//  AppDelegate.m
//  GFBS
//
//  Created by apple on 16/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "ZBLocalized.h"
#import "GFTabBarController.h"
#import "GFAdViewController.h"
#import "LoginViewController.h"
#import "DHGuidePageHUD.h"
#import "GFConst.h"

#import "JCHATCustomFormatter.h"
#import "JCHATStringUtils.h"
#import "JCHATFileManager.h"

#import <AFNetworking.h>
#import <MJExtension.h>
#import <SVProgressHUD.h>
#import <SDImageCache.h>

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用idfa功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

@interface AppDelegate () <JPUSHRegisterDelegate>

/*请求管理者*/
@property (strong , nonatomic)GFHTTPSessionManager *manager;

@end

@implementation AppDelegate

@synthesize user;

+ (AppDelegate *) APP {
    return  (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /** Fabric */
    [Fabric with:@[[Crashlytics class]]];
    
    /** Firebase */
    [FIRApp configure];
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    /** JMessage */
    [self initLogger];
    //    NSLog(@"%@",@(INTERNAL_VERSION));
    // init third-party SDK
    [JMessage addDelegate:self withConversation:nil];
    
    //    [JMessage setLogOFF];
    [JMessage setDebugMode];
    [JMessage setupJMessage:launchOptions
                     appKey:JMESSAGE_APPKEY
                    channel:CHANNEL
           apsForProduction:NO
                   category:nil
             messageRoaming:YES];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert)
                                          categories:nil];
    } else {
        //categories 必须为nil
        [JMessage registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                      UIRemoteNotificationTypeSound |
                                                      UIRemoteNotificationTypeAlert)
                                          categories:nil];
    }
    
    [self registerJPushStatusNotification];

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    /** set NSUserDefault */
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefault objectForKey:@"KEY_USER_NAME"];
    NSString *userToken = [userDefault objectForKey:@"KEY_USER_TOKEN"];
    NSString *userlang = [userDefault objectForKey:@"KEY_USER_LANG"];
    NSString *googleUserID = [userDefault objectForKey:@"googlePlusUserID"];
    NSString *facebookUserID = [userDefault objectForKey:@"facebookUserID"];
    
    if (userlang == NULL) {
        [userDefault setObject:@"en" forKey:@"KEY_USER_LANG"];
    }
    
    [userDefault synchronize];

    NSLog(@"googleUserID in appDelegate %@", googleUserID);
    NSLog(@"facebookUserID in appDelegate %@", facebookUserID);
    
    //[[InternationalControl sharedInstance]
    
    /** if last login token saved in userDefault */
    if (userToken != nil && userToken != NULL) {
        
        user = [[ZZUser alloc] init];
        user.userToken = userToken;
        NSLog(@"userToken in appdelegate %@", user.userToken);
        user.userUserName = username;
        user.preferredLanguage = userlang;
        
        //user instance
        [ZZUser shareUser].userToken = userToken;
        [ZZUser shareUser].userUserName = username;
        [ZZUser shareUser].preferredLanguage = userlang;
        [ZZUser shareUser].userGoogleID = googleUserID;
        [ZZUser shareUser].userFacebookID = facebookUserID;

        
        //初始化语言
        if ([userlang isEqualToString:@"en"]) {
            [[ZBLocalized sharedInstance]setLanguage:@"en"];
        } else if ([userlang isEqualToString:@"tw"]) {
            [[ZBLocalized sharedInstance]setLanguage:@"zh-Hant"];
        } else {
            [[ZBLocalized sharedInstance]initLanguage];
        }
        
        /** to main pages */
        //GFTabBarController *tabVC = [[GFTabBarController alloc] init];
        _tabBarCtl = [[GFTabBarController alloc] init];
        self.window.rootViewController = _tabBarCtl;
        [self.window makeKeyAndVisible];
        
        NSLog(@"userToken in default user %@", userToken);
        NSLog(@"userLang in default user %@", user.preferredLanguage);
        NSLog(@"googleUserID in default user %@", userToken);
        NSLog(@"facebookUserID in default user %@", user.preferredLanguage);
        
        return YES;
    }
    
    //广告控制器
//    GFAdViewController *adVC = [[GFAdViewController alloc]init];
    
    //GFTabBarController *tabVc = [[GFTabBarController alloc] init];
    
    /** No userDefault, then go to loginVC */
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    self.window.rootViewController = loginVC;
    [self.window makeKeyAndVisible];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:BOOLFORKEY]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOLFORKEY];
    }
    
    //guide pages
    NSArray *imageNameArray = @[@"tutorial-1242x2208-1.jpg",@"tutorial-1242x2208-2.jpg",@"tutorial-1242x2208-3.jpg"];
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.window.frame imageNameArray:imageNameArray buttonIsHidden:YES];
    [self.window addSubview:guidePage];
    
    
    
    /******** Google+ signin *********/
    NSError* configureError;
    /*
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
     */
    
    //[GIDSignIn sharedInstance].clientID = @"YOUR_CLIENT_ID";
    //[GIDSignIn sharedInstance].delegate = self;
    NSLog(@"[GGLContext sharedInstance]  in appDelegate works");
    
    /******** Facebook signin *********/
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //清除过期缓存
    [[SDImageCache sharedImageCache] cleanDisk];
    
    [GFTopWindow gf_show];
    
    
    /******** JPush *********/
    /*
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。

    [JPUSHService setupWithOption:launchOptions appKey:APPKEY
                          channel:CHANNEL
                 apsForProduction:NO
            advertisingIdentifier:advertisingId];
    */
    
    [JCHATFileManager initWithFilePath];//demo 初始化存储路径
    
    [JMessage resetBadge];
    
    return YES;
}

//************************* Facebook ************************//

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [FBSDKAppEvents activateApp];
}


// [START openurl]
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"application openURL");
    
    /** Facebook */
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
    
    /** Google+ */
    else if ([[GIDSignIn sharedInstance] handleURL:url
                                   sourceApplication:sourceApplication
                                          annotation:annotation]) {
        NSLog(@"GIDSignIn openURL works");
        return YES;
    }
    
    return NO;
    
}
// [END openurl]

/*
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options
{
    NSLog(@"URL in other Method %@",url);
    if ([[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]){
        return YES;
    }
    else if ([[FBSDKApplicationDelegate sharedInstance]application:app openURL:url options:options]){
        return YES;
    }
    
    // If you handle other (non Twitter Kit) URLs elsewhere in your app, return YES. Otherwise
    return NO;
}
*/


/************************* Google+ ************************/

// [START signin_handler]
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error == nil) {
        /**from Firebase*/
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error %@", error.localizedDescription);
            }
        }];
        
        
        /**Google signin*/
        NSString *userId = user.userID;                  // For client-side use only!
        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        NSString *fullName = user.profile.name;
        NSString *givenName = user.profile.givenName;
        NSString *familyName = user.profile.familyName;
        NSString *email = user.profile.email;
        
        if (user.profile.hasImage)
        {
            NSURL *googleProfileImageUrl = [user.profile imageURLWithDimension:100];
            NSLog(@"googleProfileImageUrl : %@", googleProfileImageUrl);
            [ZZUser shareUser].googleProfileImageUrl = googleProfileImageUrl;
        }
        
        // [START_EXCLUDE]
        NSDictionary *statusText = @{@"statusText":
                                         [NSString stringWithFormat:@"Signed in user: %@",
                                          fullName]};
        NSLog(@"UserName in GooglePlus %@",fullName);
        NSLog(@"UserId in GooglePlus %@",userId);
        NSLog(@"didSignInForUser:(GIDGoogleUser *)user in appDelegate works");
        
        [ZZUser shareUser].userGoogleID = userId;
        
        //From integrations demo
        [[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"googlePlusLogin"];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"googlePlusUserID"];
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"googlePlusUserImageUrl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ForceUpdateLocation" object:self userInfo:[NSDictionary dictionaryWithObject:fullName?:@"" forKey:@"full_name"]];
        // end of From integrations demo
        
        [self googleLogin];
    } else {
        NSLog(@"Error %@", error.localizedDescription);
    }
    
    /*
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ToggleAuthUINotification"
     object:nil
     userInfo:statusText];
     */
    // [END_EXCLUDE]
}
// [END signin_handler]


// This callback is triggered after the disconnect call that revokes data
// access to the user's resources has completed.
// [START disconnect_handler]
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // [START_EXCLUDE]
    NSDictionary *statusText = @{@"statusText": @"Disconnected user" };
    
    /*
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ToggleAuthUINotification"
     object:nil
     userInfo:statusText];
     */
    
    // [END_EXCLUDE]
    
    NSLog(@"didDisconnectWithUser:(GIDGoogleUser *)user works");
}
// [END disconnect_handler]

- (void)googleLogin {
    
    NSDictionary *inSubData = @ {@"googleId" : [ZZUser shareUser].userGoogleID};
    NSDictionary *inData = @{
                             @"action" : @"googleLogin",
                             @"data" : inSubData};
    NSDictionary *parameters = @{@"data" : inData};
    
    NSLog(@"upcoming events parameters %@", parameters);
    
    [[GFHTTPSessionManager shareManager] POSTWithURLString:GetURL parameters:parameters success:^(id data) {
        
        ZZUser *thisUser = [[ZZUser alloc] init];
        thisUser = [ZZUser mj_objectWithKeyValues:data[@"data"]];
        
        if (thisUser == nil) {
            
            [SVProgressHUD showWithStatus:@"Incorrect Email or password ><"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        } else {
            
            [AppDelegate APP].user = [[ZZUser alloc] init];
            [AppDelegate APP].user = thisUser;
            
            NSLog(@"user token = %@", thisUser.userToken);
            
            
            //*************** defualt user set even app is turned off *********//
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:thisUser.userUserName forKey:@"KEY_USER_NAME"];
            [userDefaults setObject:thisUser.userToken forKey:@"KEY_USER_TOKEN"];
            
            thisUser.preferredLanguage = @"en"; //should add this parameter in google login API
            [userDefaults setObject:thisUser.preferredLanguage forKey:@"KEY_USER_LANG"];
            [userDefaults synchronize];
            
            NSLog(@"this user %@", thisUser);
            NSLog(@"this user. userName %@", thisUser.usertName);
            NSLog(@"this user. memberId %@", thisUser.userID);
            NSLog(@"this user. preferredLanguage %@", thisUser.preferredLanguage);
            
            //*************** user instance *********//
            [ZZUser shareUser].userID = thisUser.userID;
            [ZZUser shareUser].userUpdatedAt = thisUser.userUpdatedAt;
            [ZZUser shareUser].userCreatedAt = thisUser.userCreatedAt;
            [ZZUser shareUser].usertName = thisUser.usertName;
            [ZZUser shareUser].userEmail = thisUser.userEmail;
            //[ZZUser shareUser].usertPassword = thisUser.usertPassword;
            [ZZUser shareUser].userUserName = thisUser.userUserName;
            [ZZUser shareUser].userStatus = thisUser.userStatus;
            [ZZUser shareUser].userToken = thisUser.userToken;
            //[ZZUser shareUser].userFacebookID = thisUser.userFacebookID;
            //[ZZUser shareUser].userGoogleID = thisUser.userGoogleID;
            [ZZUser shareUser].userOrganizingExp = thisUser.userOrganizingExp;
            [ZZUser shareUser].userOrganizingLevel = thisUser.userOrganizingLevel;
            [ZZUser shareUser].socialExp = thisUser.socialExp;
            [ZZUser shareUser].socialLevel = thisUser.socialLevel;
            [ZZUser shareUser].checkinPoint = thisUser.checkinPoint;
            [ZZUser shareUser].userInterests = [[NSMutableArray alloc] init];
            [ZZUser shareUser].userInterests = thisUser.userInterests;
            [ZZUser shareUser].userLastCheckIn = thisUser.userLastCheckIn;
            [ZZUser shareUser].age = thisUser.age;
            [ZZUser shareUser].gender = thisUser.gender;
            [ZZUser shareUser].userIndustry = thisUser.userIndustry;
            [ZZUser shareUser].userProfession = thisUser.userProfession;
            [ZZUser shareUser].maxPrice = thisUser.maxPrice;
            [ZZUser shareUser].minPrice = thisUser.minPrice;
            [ZZUser shareUser].preferredLanguage = thisUser.preferredLanguage;
            [ZZUser shareUser].numOfFollower = thisUser.numOfFollower;
            [ZZUser shareUser].showOnLockScreen = thisUser.showOnLockScreen;
            [ZZUser shareUser].sounds = thisUser.sounds;
            [ZZUser shareUser].emailNotification = thisUser.emailNotification;
            [ZZUser shareUser].allowNotification = thisUser.allowNotification;
            [ZZUser shareUser].canSeeMyProfile = thisUser.canSeeMyProfile;
            [ZZUser shareUser].canMessageMe = thisUser.canMessageMe;
            [ZZUser shareUser].canMyFriendSeeMyEmail = thisUser.canMyFriendSeeMyEmail;
            [ZZUser shareUser].notificationNum = thisUser.notificationNum;
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.rootViewController = [[GFTabBarController alloc]init];
            [window makeKeyWindow];
            
        }
        
        
    } failed:^(NSError *error) {
        [SVProgressHUD showWithStatus:@"Busy network, please try later~"];
        [SVProgressHUD dismiss];
    }];
    
}

//JPush
- (void)registerJPushStatusNotification {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidSetup:)
                          name:kJMSGNetworkDidSetupNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkIsConnecting:)
                          name:kJMSGNetworkIsConnectingNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidClose:)
                          name:kJMSGNetworkDidCloseNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJMSGNetworkDidRegisterNotification
                        object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJMSGNetworkDidLoginNotification
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(receivePushMessage:)
                          name:kJMSGNetworkDidReceiveMessageNotification
                        object:nil];
    
}

- (void)networkDidSetup:(NSNotification *)notification {
    DDLogDebug(@"Event - networkDidSetup");
}

- (void)networkIsConnecting:(NSNotification *)notification {
    DDLogDebug(@"Event - networkIsConnecting");
}

- (void)networkDidClose:(NSNotification *)notification {
    DDLogDebug(@"Event - networkDidClose");
}

- (void)networkDidRegister:(NSNotification *)notification {
    DDLogDebug(@"Event - networkDidRegister");
}

- (void)networkDidLogin:(NSNotification *)notification {
    DDLogDebug(@"Event - networkDidLogin");
}

- (void)receivePushMessage:(NSNotification *)notification {
    DDLogDebug(@"Event - receivePushMessage");
    
    NSDictionary *info = notification.userInfo;
    if (info) {
        DDLogDebug(@"The message - %@", info);
    } else {
        DDLogWarn(@"Unexpected - no user info in jpush mesasge");
    }
}

//JPush
- (void)initLogger {
    JCHATCustomFormatter *formatter = [[JCHATCustomFormatter alloc] init];
    
    // XCode console
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Apple System
    [[DDASLLogger sharedInstance] setLogFormatter:formatter];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 一个LogFile的有效期长，有效期内Log都会写入该LogFile
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;//最多LogFile的数量
    [fileLogger setLogFormatter:formatter];
    [DDLog addLogger:fileLogger];
}

//Jpush
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


- (void)setupMainTabBar {
    NSLog(@"JMessage-setupMainTabBar worked");
    _tabBarCtl = [[GFTabBarController alloc] init];
    _tabBarCtl.loginIdentify = kFirstLogin;
    self.window.rootViewController = _tabBarCtl;
    [self.window makeKeyAndVisible];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
