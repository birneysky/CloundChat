//
//  CCEmojiPreview.h
//  CloudChat
//
//  Created by birneysky on 2017/4/11.
//  Copyright © 2017年 binrey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCEmojiPreview : UIView

+ (instancetype)emojiPreview;

- (void)setPreviewImage:(UIImage*)image;

- (void)setEmojiName:(NSString*)name;

- (void)showFromView:(UIView*)view;

@end
