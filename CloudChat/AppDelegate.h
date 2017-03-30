//
//  AppDelegate.h
//  CloudChat
//
//  Created by birney on 2017/3/28.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMReceiveMessageDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

