//
//  CCBusinessCardMessage.h
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define CCBusinessCardMessageTypeIdentifier @"RCD:BusinessCardMsg"


/**
 自定义消息类
 */
@interface CCBusinessCardMessage : RCMessageContent

@property (nonatomic,copy) NSString* nickName;

@property (nonatomic,copy) NSString* title;

@property (nonatomic,copy) NSString* avatarURL;


/**
 名片消息便捷构造方法

 @param nickName 姓名
 @param title 头衔
 @param url 图像地址
 @return 实例
 */
+ (instancetype) messageWithName:(NSString*)nickName
                           title:(NSString*)title
                       avatarUrl:(NSString*)url;

@end
