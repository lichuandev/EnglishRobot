//
//  AppDelegate.m
//  ERobot
//
//  Created by Mac on 17/2/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "AppDelegate.h"
#import "ERDatabaseTool.h"
#import "ERDataTool.h"
#import "ERResult.h"
#import <UMSocialCore/UMSocialCore.h>
#define USHARE_DEMO_APPKEY @"5861e5daf5ade41326001eab"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = [UIImage imageNamed:@"返回"];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].backIndicatorImage = [UIImage imageNamed:@"返回"];
//    [UMSocialData setAppKey:@"	576ce52ae0f55a4930002858"];
//    [UMSocialWechatHandler setWXAppId:@"wx69d5b71f4328bcd5" appSecret:@"d4624c36b6795d1d99dcf0547af5443d" url:@"http://www.baidu.com"];
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_DEMO_APPKEY];
    
    [self configUSharePlatforms];
    
    [self confitUShareSettings];
    return YES;
}
- (void)confitUShareSettings
{
       [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxdc1e388c3822c80b" appSecret:@"3baf1193c85774b3fd9d18447d76cab0" redirectURL:@"http://mobile.umeng.com/social"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105821097"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    NSString *dateS = [self getCurrentTime];
    [[NSUserDefaults standardUserDefaults] setObject:dateS forKey:@"dateS"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString *dateS = [[NSUserDefaults standardUserDefaults] stringForKey:@"dateS"];
    NSLog(@"记录的时间：%@",dateS);
    NSString *currentD = [self getCurrentTime];
    if (![dateS isEqualToString:currentD]) {
        NSString *s = @"select * from allWordsTable where time = ?";
        
        NSArray *array = [ERDatabaseTool readDb:s para:dateS];
        if (array.count>0) {
            NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"result"];
            ERResult *result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (result.studyDays) {
                NSLog(@"学习天数：%d,学习单词：%d",result.studyDays,result.totalWords);
                result.studyDays = result.studyDays + 1;
                result.totalWords = result.totalWords + (int)array.count;
            }else{
                result = [[ERResult alloc] init];
                result.studyDays = 1;
                result.totalWords = (int)array.count;
            }
            NSData *resultData = [NSKeyedArchiver archivedDataWithRootObject:result];
            [[NSUserDefaults standardUserDefaults] setObject:resultData forKey:@"result"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (array.count >= 20) {
                NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:@"age"];
                if (!age) {
                    age = 1;
                }else{
                    age += 1;
                }
                [[NSUserDefaults standardUserDefaults] setInteger:age forKey:@"age"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    }else{
        NSLog(@"是同一天");
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(NSString *)getCurrentTime{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateS = [dateFormatter stringFromDate:date];
    return dateS;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}
@end
