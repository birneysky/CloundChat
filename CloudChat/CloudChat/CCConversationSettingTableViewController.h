//
//  CCConversationSettingTableViewController.h
//  CloudChat
//
//  Created by birney on 2017/4/7.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMLib/RongIMLib.h>

@interface CCConversationSettingTableViewController : UITableViewController

@property (nonatomic, assign) RCConversationType conversationType;

@property (nonatomic, copy) NSString* targetId;

@property (nonatomic,assign) BOOL isDisturb;

@property (nonatomic, assign) BOOL isTop;

@end
