//
//  CCBusinessCardMessage.m
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCBusinessCardMessage.h"

@implementation CCBusinessCardMessage


#pragma mark - Init
+ (instancetype) messageWithName:(NSString*)nickName
                           title:(NSString*)title
                       avatarUrl:(NSString*)url
{
    CCBusinessCardMessage* msg = [CCBusinessCardMessage new];
    msg.nickName = nickName;
    msg.title = title;
    msg.avatarURL = url;
    return msg;
}

+ (RCMessagePersistent)persistentFlag
{
  return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

#pragma mark -  RCMessageCoding
- (void)decodeWithData:(NSData *)data
{
    if (data) {
        NSError* error = nil;
        NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (dict) {
            self.nickName = dict[@"nickName"];
            self.title = dict[@"title"];
            self.avatarURL = dict[@"avatarURL"];
            NSDictionary* userInfo = dict[@"user"];
            [self decodeUserInfo:userInfo];
        }
    }
}

- (NSData*)encode
{
    NSMutableDictionary* dataDic = [[NSMutableDictionary alloc] init];
    if (self.nickName.length > 0) {
        [dataDic setObject:self.nickName forKey:@"nickName"];
    }
    
    if (self.title.length > 0) {
        [dataDic setObject:self.title forKey:@"title"];
    }
    
    if (self.avatarURL.length > 0) {
        [dataDic setObject:self.avatarURL forKey:@"avatarURL"];
    }
    
    if (self.senderUserInfo) {
        NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
        if (self.senderUserInfo.name) {
            [userInfoDic setObject:self.senderUserInfo.name
                 forKeyedSubscript:@"name"];
        }
        if (self.senderUserInfo.portraitUri) {
            [userInfoDic setObject:self.senderUserInfo.portraitUri
                 forKeyedSubscript:@"icon"];
        }
        if (self.senderUserInfo.userId) {
            [userInfoDic setObject:self.senderUserInfo.userId
                 forKeyedSubscript:@"id"];
        }
        [dataDic setObject:userInfoDic forKey:@"user"];
    }
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:dataDic options:kNilOptions error:nil];
    return data;
}


/// 会话列表中显示的摘要
- (NSString *)conversationDigest {
    return [NSString stringWithFormat:@"[名片] %@",self.nickName];
}

///消息的类型名
+ (NSString *)getObjectName {
    return CCBusinessCardMessageTypeIdentifier;
}


@end
