//
//  CCSightPlayer.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/28.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSightTransport.h"

@interface CCSightPlayer : UIView


- (id)initWithPlayer:(AVPlayer *)player;

@property (nonatomic, readonly) id <CCSightTransport> transport;

@end
