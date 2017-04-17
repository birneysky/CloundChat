//
//  CCTextField.m
//  CloudChat
//
//  Created by birneysky on 2017/4/16.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCTextField.h"

@implementation CCTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

@end
