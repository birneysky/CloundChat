//
//  AppDelegate.m
//  CloudChat
//
//  Created by birney on 2017/3/28.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate () 

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[RCIM sharedRCIM] initWithAppKey:@"lmxuhwaglck9d"];
    
    return YES;
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


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - RCIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    NSLog(@"🍎🍎🍎 getUserInfoWithUserId %@",userId);
    RCUserInfo* userInfo = [[RCUserInfo alloc] init];
    userInfo.userId = userId;
    userInfo.name = [NSString stringWithFormat:@"🍎 %@",userId];
    userInfo.portraitUri = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490766912476&di=e000b985b4374e394793d99b34da8121&imgtype=0&src=http%3A%2F%2Fpic36.nipic.com%2F20131207%2F4499633_224151069363_2.jpg";
    completion(userInfo);
}


#pragma mark - RCIMGroupInfoDataSource

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion
{
    NSLog(@"🍏🍏🍏🍏🍏🍏🍏🍏 getGroupInfoWithGroupId  %@",groupId);
    
    RCGroup* group = [[RCGroup alloc] init];
    group.groupId = groupId;
    group.groupName = [NSString stringWithFormat:@"🍏 %@",groupId];
    completion(group);
}


#pragma mark - RCIMReceiveMessageDelegate
- (void)onRCIMReceiveMessage:(RCMessage *)message
                        left:(int)left
{

}


-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message
                      withSenderName:(NSString *)senderName
{
    return YES;
}

/// 返回YES 关闭消息提示音
-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message
{
    return  NO;
}

@end
