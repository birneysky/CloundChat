//
//  CCEmojiButton.m
//  CloudChat
//
//  Created by birneysky on 2017/4/11.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCEmojiButton.h"

@implementation CCEmojiButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return (CGRect){8,8,contentRect.size.width - 16,contentRect.size.height-16};
}



@end
