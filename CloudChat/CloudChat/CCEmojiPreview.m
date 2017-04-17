//
//  TEEmojiPreview.m
//  CloudChat
//
//  Created by birneysky on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCEmojiPreview.h"

@interface CCEmojiPreview ()
@property (weak, nonatomic) IBOutlet UIImageView *emojiImageView;
@property (weak, nonatomic) IBOutlet UILabel *emojiNameLabel;

@end

@implementation CCEmojiPreview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)emojiPreview
{
    return [[[NSBundle mainBundle] loadNibNamed:@"CCEmojiPreview" owner:self options:nil] lastObject];
}

- (void)showFromView:(UIView*)view
{
    UIWindow* window = [UIApplication sharedApplication].windows.lastObject;
    if (!self.superview) {
        [window addSubview:self];
    }
    
    CGRect frameInWindow =  [view convertRect:view.bounds toView:nil];

    self.center = (CGPoint){frameInWindow.origin.x + frameInWindow.size.width / 2, frameInWindow.origin.y - frameInWindow.size.height / 2};
}



- (void)setPreviewImage:(UIImage*)image
{
    self.emojiImageView.image = image;
}

- (void)setEmojiName:(NSString*)name
{
    self.emojiNameLabel.text = name;
}


@end
