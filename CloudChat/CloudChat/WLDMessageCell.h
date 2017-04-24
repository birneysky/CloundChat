//
//  WLDMessageCell.h
//  WeiLingDi
//
//  Created by WLD on 2017/4/11.
//  Copyright © 2017年 syyp. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>


@interface WLDMessageCell : RCMessageCell

/*!
 文本内容的Label
 */
@property(strong, nonatomic) UILabel *textLabel;

/*!
 背景View
 */
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*!
 根据消息内容获取显示的尺寸
 
 @param message 消息内容
 
 @return 显示的View尺寸
 */
//+ (CGSize)getBubbleBackgroundViewSize:(WLD_KMessage *)message;

@end
