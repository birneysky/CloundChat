//
//  WLDMessageCell.m
//  WeiLingDi
//
//  Created by WLD on 2017/4/11.
//  Copyright © 2017年 syyp. All rights reserved.
//

#import "WLDMessageCell.h"

#define Test_Message_Font_Size 16

@implementation WLDMessageCell

//根据消息内容计算cell大小
+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
//    WLD_KMessage *message = (WLD_KMessage *)model.content;
    model.isDisplayMessageTime = NO;
//    CGSize size = [WLDMessageCell getBubbleBackgroundViewSize:message];
//    
//    CGFloat __messagecontentview_height = size.height;
//    __messagecontentview_height += extraHeight;
    
//    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 150);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.bubbleBackgroundView.backgroundColor = [UIColor redColor];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress =
    [[UILongPressGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(longPressed:)];
    [self.bubbleBackgroundView addGestureRecognizer:longPress];
}

#pragma mark - 手势方法

//长按方法
- (void)longPressed:(id)sender {
    UILongPressGestureRecognizer *press = (UILongPressGestureRecognizer *)sender;
    if (press.state == UIGestureRecognizerStateEnded) {
        return;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongTouchMessageCell:self.model
                                        inView:self.bubbleBackgroundView];
    }
}

//点击方法

- (void)tapTextMessage:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
        [self.delegate didTapMessageCell:self.model];
    }
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    
    [self setAutoLayout];
}

- (void)setAutoLayout {
//    WLD_KMessage *testMessage = (WLD_KMessage *)self.model.content;
//
//    CGRect messageContentViewRect = self.messageContentView.frame;
//    messageContentViewRect.size.width = 130;
//    
//    NSInteger index = [testMessage.content integerValue] + 1;
//    NSString *name = [NSString stringWithFormat:@"%ld_custom",(long)index];
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
//    NSData *imageGifData = [NSData dataWithContentsOfFile:filePath];
//    
//    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageGifData];
//    self.bubbleBackgroundView.animatedImage = animatedImage;

    //接受
    if (MessageDirection_RECEIVE == self.messageDirection) {
        
        CGRect rect = CGRectMake(10.0f, 10.0f, 120.0f, 120.0f);
        self.bubbleBackgroundView.frame = rect;
    } else {//发送
        
        CGRect rect = CGRectMake(self.messageContentView.frame.size.width - 130, 10, 120, 120);
        self.bubbleBackgroundView.frame = rect;
    }
}
@end
