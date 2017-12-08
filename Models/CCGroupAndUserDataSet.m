//
//  GroupAndUserDataSet.m
//  CloudChat
//
//  Created by birney on 2017/3/31.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCGroupAndUserDataSet.h"

static CCGroupAndUserDataSet* _defalutSet = nil;

@interface CCGroupAndUserDataSet ()

@property(nonatomic,strong) NSMutableDictionary* userDic;

@property(nonatomic,strong) NSMutableDictionary* groupDic;

@end


@implementation CCGroupAndUserDataSet

#pragma mark - Init
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_defalutSet) {
        _defalutSet = [super allocWithZone:zone];
    }
    return _defalutSet;
}

+ (instancetype)defalutSet
{
    if(!_defalutSet){
        _defalutSet = [[CCGroupAndUserDataSet alloc] init];
        [_defalutSet refreshUserInfo];
        [_defalutSet refreshGroupInfo];
    }
    return _defalutSet;
}

- (NSString*)currentUserID
{
    return [RCIMClient sharedRCIMClient].currentUserInfo.userId;
}


- (NSArray<NSString*>*)allUserIds
{
    return self.userDic.allKeys;
}

#pragma mark - Helper
- (void)refreshUserInfo
{
    __weak typeof(self) weakSelf = self;
    [self.userDic enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSArray*  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray* infos = weakSelf.userDic[key];
        RCUserInfo* userInfo = [[RCUserInfo alloc] init];
        userInfo.userId = key;
        userInfo.name = infos[0];
        userInfo.portraitUri = infos[1];
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:key];
    }];
}


- (void)refreshGroupInfo
{
    ///segue_show_conversation_detail__weak typeof(self) weakSelf = self;
    [self.groupDic enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull groupId, NSDictionary*  _Nonnull obj, BOOL * _Nonnull stop) {
       /// NSDictionary* groupInfo = self.groupDic[groupId];
        
        RCGroup* group = [[RCGroup alloc] init];
        group.groupId = groupId;
        group.groupName = obj[@"name"];
        [[RCIM sharedRCIM] refreshGroupInfoCache:group withGroupId:groupId];
    }];
}

#pragma mark - Properties
- (NSMutableDictionary*)userDic
{
    if(!_userDic){
        _userDic = [[NSMutableDictionary alloc] initWithDictionary:@{
                     @"user0":@[@"段誉",@"http://gss0.bdstatic.com/94o3dSag_xI4khGkpoWK1HF6hhy/baike/c0%3Dbaike92%2C5%2C5%2C92%2C30/sign=353bb3afad51f3ded7bfb136f5879b7a/gi
                    
                    
                    }];
    }
    return _userDic;
}

- (NSMutableDictionary*)groupDic
{
    if (!_groupDic) {
        _groupDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"group1":@{@"name":@"🍑 group1",@"users":@[@"user0",@"user1",@"user2",@"user3",@"user4",@"user5",@"user6",@"user7",@"user8",@"user9",@"user10",@"user100"]},
                                                                      @"group2":@{@"name":@"全球手机项目组",@"users":@[@"user1",@"user3"]},
                                                                      @"AppleGroup":@{@"name":@"🍏 AppleGroup",@"users":@[@"user1",@"user2"]}}];
    }
    return _groupDic;
}


#pragma mark - RCIMUserInfoDataSource

- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    NSLog(@"🍎🍎🍎 getUserInfoWithUserId %@",userId);
    NSArray* infos = self.userDic[userId];
    RCUserInfo* userInfo = [[RCUserInfo alloc] init];
    userInfo.userId = userId;
    userInfo.name = infos[0];
    userInfo.portraitUri = infos[1];
    completion(userInfo);
}


#pragma mark - RCIMGroupInfoDataSource

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion
{
    NSLog(@"🍏🍏🍏🍏🍏🍏🍏🍏 getGroupInfoWithGroupId  %@",groupId);
    NSDictionary* groupInfo = self.groupDic[groupId];
    
    RCGroup* group = [[RCGroup alloc] init];
    group.groupId = groupId;
    group.groupName = groupInfo[@"name"];
    completion(group);
}

#pragma mark - RCIMGroupUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion
{
    NSLog(@"🍑🍑🍑🍑🍑🍑🍑🍑🍑🍑 userid %@,groupid %@",userId,groupId);
    NSArray* infos = self.userDic[userId];
    RCUserInfo* userInfo = [[RCUserInfo alloc] init];
    userInfo.userId = userId;
    userInfo.name = infos[0];
    userInfo.portraitUri = infos[1];
    completion(userInfo);
}

#pragma mark - RCIMGroupMemberDataSource
- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray<NSString *> *userIdList))resultBlock
{
    NSDictionary* groupInfo = self.groupDic[groupId];
    NSArray* users = groupInfo[@"users"];
    resultBlock(users);
}


@end
