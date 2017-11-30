//
//  AppDelegate.h
//  GFBS
//
//  Created by apple on 16/11/15.
//  Copyright © 2016年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZUser.h"
#import "Crashlytics/Crashlytics.h"
#import "GFTabBarController.h"

#import "JChatConstants.h"
#import <JMessage/JMessage.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Fabric/Fabric.h>
#import <Firebase.h>

#define UMENG_APPKEY @"55487cee67e58e5431003b06"

// 需要填写为您自己的 JPush Appkey
#define JMESSAGE_APPKEY @"3367a80b768bfc766f8b273b"

#define CHANNEL @"Publish channel"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate, JMessageDelegate>
{
    UIAlertView *myAlertView;
}
@property (nonatomic,strong) GFTabBarController *tabBarCtl;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ZZUser *user;
+ (AppDelegate *) APP;

@property (assign, nonatomic)BOOL isDBMigrating;
@property (assign, nonatomic) BOOL chatLogined;

- (void)setupMainTabBar;

@end

