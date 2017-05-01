//
//  RCSightMessage.h
//  RongIMLib
//
//  Created by LiFei on 2016/12/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

/*!
 小视频消息的类型名
 */
#define RCSightMessageTypeIdentifier @"RC:SightMsg"

/**
 小视频消息类
 
 @discussion 小视频消息类，此消息会进行存储并计入未读消息数。
 */
@interface CCSightMessage : RCMessageContent <NSCoding>

/*!
 本地URL地址
 */
@property(nonatomic, strong) NSString *localPath;

/*!
 网络URL地址
 */
@property(nonatomic, strong) NSString *remoteUrl;

/*!
 缩略图
 */
@property(nonatomic, strong) UIImage *thumbnailImage;


+ (instancetype)messageWithLocalPath:(NSString*)path thumbnail:(UIImage*)image;

@end
