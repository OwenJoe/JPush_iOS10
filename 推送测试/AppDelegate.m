//
//  AppDelegate.m
//  推送测试
//
//  Created by imac on 2016/10/12.
//  Copyright © 2016年 imac. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
#import <UserNotifications/UserNotifications.h>
#import <AdSupport/AdSupport.h>

#import "OneViewController.h"
#import "TwoViewController.h"

static NSString *appKey = @"772bcfaaa1386ad1a5d8039e";
static NSString *channel = @"Publish channel";
static BOOL isProduction = FALSE;

@interface AppDelegate ()<JPUSHRegisterDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    OneViewController *oneVc =[[OneViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:oneVc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    //Required
    // init Push(2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil  )
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //关闭APN推送
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
    
    return YES;
}


#warning 点击推送进来,清除角标数量
- (void)applicationDidEnterBackground:(UIApplication *)application {
    //使用这个方法来释放共享资源，保存用户数据，无效
    //定时器，并存储足够的应用程序状态信息以恢复您的
    //应用程序到其目前的状态，以防它被终止。
    //如果您的应用程序支持后台执行，则调用此方法
    //而不是applicationWillTerminate:当用户退出。
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];//清除本地角标数量为0
    [JPUSHService setBadge:0];//通报服务器,角标数量为0,否则有消息推送,会在之前基础上+1
    [[UIApplication sharedApplication]cancelAllLocalNotifications];//取消任何通知标志
    
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    
}

#warning 回调失败的时候
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"回调失败了: %@", error);
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

#warning 只有点击消息推送之后才会进来,获取推送内容,跳转页面,都在这个回调里边
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"系统推送内容%@",userInfo);
        
        NSLog(@"点击推送进来");
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[TwoViewController alloc]init]];
        //跳转到指定页面,rootViewController
        [self.window.rootViewController presentViewController:nav animated:YES completion:^{
            
        }];
        
    }
    completionHandler();  // 系统要求执行这个方法
    
    
}


#warning 程序无论在前后台都会执行这个方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
    
}















@end
