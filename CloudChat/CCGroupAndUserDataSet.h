//
//  GroupAndUserDataSet.h
//  CloudChat
//
//  Created by birney on 2017/3/31.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface CCGroupAndUserDataSet : NSObject <RCIMUserInfoDataSource,
                                             RCIMGroupInfoDataSource,
                                             RCIMGroupUserInfoDataSource,
                                             RCIMGroupMemberDataSource>

+ (instancetype)defalutSet;

@end
