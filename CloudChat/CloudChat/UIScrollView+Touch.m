//
//  UIScrollView+Touch.m
//  CloudChat
//
//  Created by birney on 2017/4/6.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "UIScrollView+Touch.h"

@implementation UIScrollView (Touch)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

#pragma clang diagnostic pop

@end
