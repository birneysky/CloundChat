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
                    @"user0":@[@"Steve Jobs",@"http://g.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=61f086829416fdfad86cc1e88cb4eb69/a08b87d6277f9e2fc11760a11630e924b899f37d.jpg"],
                    @"user1":@[@"Tim Cook",@"http://g.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=092984c38126cffc692ab8b4813a2dad/4ec2d5628535e5dd597d578575c6a7efce1b6213.jpg"],
                    @"user2":@[@"罗永浩",@"http://a.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=fb13bec8caea15ce41eee70f8e3b5dce/d1160924ab18972b2c2fd087e5cd7b899e510a62.jpg"],
                    @"user3":@[@"雷军",@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=de25d952b7b7d0a27bc9039bf3d41134/024f78f0f736afc30a208a85b619ebc4b7451225.jpg"],
                    @"user4":@[@"李彦宏",@"http://b.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=c091c5ca0bfa513d51aa6bd8055632c6/314e251f95cad1c8f698ac317c3e6709c93d5180.jpg"],
                    @"user5":@[@"马云",@"http://e.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=0003b03088b1cb133e693b15e56f3173/0bd162d9f2d3572c257447038f13632763d0c35f.jpg"],
                    @"user6":@[@"马化腾",@"http://a.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=bf1f9fba0f082838680ddb1280a2ce3c/8cb1cb1349540923453457db9a58d109b3de4931.jpg"],
                    @"user7":@[@"Bill Gates",@"http://h.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=c4c57ecf3a12b31bc76cca2fbe235147/9c16fdfaaf51f3de03c75bec97eef01f3b2979c5.jpg"],
                    @"user8":@[@"丁磊",@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=6a7cb8a553fbb2fb342b5f1477714799/c8177f3e6709c93d435dbe0f993df8dcd000549e.jpg"],
                    @"user9":@[@"周鸿祎",@"http://a.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=0d6609aebab7d0a27bc9039bf3d41134/024f78f0f736afc3d9635a79bb19ebc4b74512ba.jpg"],
                    @"user10":@[@"张朝阳",@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=19d390157cf40ad115e4c0e56f1776e2/cdbf6c81800a19d8af96232834fa828ba61e4601.jpg"],
                    @"user100":@[@"刘强东",@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=6f0cf4b7da1b0ef46ce89f58e5ff36e7/37d3d539b6003af3f14960f93d2ac65c1138b6bc.jpg"]
                    
//                    @"user7":@[@"俞敏洪",@"hhttp://g.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=945e0cac7bf40ad115e4c0e56f1776e2/cdbf6c81800a19d8221bbf9133fa828ba61e460d.jpg"],
//                    @"user7":@[@"程维",@"http://a.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=8281956fa0d3fd1f3609a53c08754222/6c224f4a20a4462309fda3239022720e0cf3d7bf.jpg"]
                    
                    
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
