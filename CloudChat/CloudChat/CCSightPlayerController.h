//
//  CCSightController.h
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/29.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCSightPlayerController : NSObject

- (id)initWithURL:(NSURL *)assetURL;

@property (strong, nonatomic, readonly) UIView *view;

- (UIImage*)generateThumbnail;

@end
