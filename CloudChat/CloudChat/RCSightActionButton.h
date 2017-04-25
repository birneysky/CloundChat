//
//  RCSightActionButton.h
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/25.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,RCSightActionState){
  RCSightActionStateBegin = 0,
  RCSightActionStateMoving,
  RCSightActionStateWillCancel,
  RCSightActionStateDidCancel,
  RCSightActionStateEnd,
  RCSightActionStateClick
};




@interface RCSightActionButton : UIView

@property (nonatomic,copy) void (^action)(RCSightActionState state);

@end
