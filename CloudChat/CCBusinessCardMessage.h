//
//  CCBusinessCardMessage.h
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#define RCDTestMessageTypeIdentifier @"RCD:BusinessCardMsg"

@interface CCBusinessCardMessage : RCMessageContent

@property (nonatomic,copy) NSString* nickName;

@property (nonatomic,copy) NSString* title;

@property (nonatomic,copy) NSString* avatarURL;

@end
