//
//  BussinessCardCell.m
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCBusinessCardCell.h"
#import "CCBusinessCardMessage.h"
#import <YYWebImage/YYWebImage.h>

@interface CCBusinessCardCell ()

@property (nonatomic, strong) UIImageView* bubbleBGView;

@property (nonatomic ,strong) YYAnimatedImageView* avatarView;

@property (nonatomic, strong) UILabel* nickNameLabel;

@property (nonatomic, strong) UILabel* titleLabel;

@end

@implementation CCBusinessCardCell



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder*)acoder{
    if (self = [super initWithCoder:acoder]) {
        [self setUp];
    }
    return  self;
}


- (void)setUp{
    self.bubbleBGView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.avatarView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
    self.nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    self.bubbleBGView.userInteractionEnabled = YES;
    
    [self.messageContentView addSubview:self.bubbleBGView];
    [self.messageContentView addSubview:self.avatarView];
    [self.messageContentView addSubview:self.nickNameLabel];
    [self.messageContentView addSubview:self.titleLabel];
    
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.bubbleBGView addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer* longPrewwGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.bubbleBGView addGestureRecognizer:longPrewwGesture];
}

- (void)setDataModel:(RCMessageModel *)model
{
    [super setDataModel: model];
    CGSize bubbleSize = [[self class]  getBubbleSize];
    if (MessageDirection_RECEIVE == self.messageDirection) {
        self.bubbleBGView.frame = CGRectMake(0, 0, bubbleSize.width, bubbleSize.height);
        UIImage *image = [RCKitUtility imageNamed:@"chat_from_bg_normal"
                                         ofBundle:@"RongCloud.bundle"];
        self.bubbleBGView.image = [image
                                           resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8,
                                                                                        image.size.width * 0.8,
                                                                                        image.size.height * 0.2,
                                                                                        image.size.width * 0.2)];
        CGFloat avatarHeight = bubbleSize.height - 8 * 2;
        self.avatarView.frame = CGRectMake(14, 8, avatarHeight, avatarHeight);
        //self.avatarView.backgroundColor = [UIColor redColor];
        
        CGFloat maxX = CGRectGetMaxY(self.avatarView.frame);
        CGFloat maxY = CGRectGetMaxY(self.avatarView.frame);
        self.nickNameLabel.frame = CGRectMake(maxX + 10, 8, 100, 21);
        //self.nickNameLabel.backgroundColor = [UIColor blueColor];
    
        self.titleLabel.frame = CGRectMake(maxX + 10, maxY - 21, 100, 21);
        //self.titleLabel.backgroundColor = [UIColor orangeColor];
        
        CCBusinessCardMessage* bussionCardMessage = (CCBusinessCardMessage*)model.content;
        self.nickNameLabel.text = bussionCardMessage.nickName;
        self.titleLabel.text = bussionCardMessage.title;
        self.avatarView.yy_imageURL = [NSURL URLWithString:bussionCardMessage.avatarURL];
    
    }
    else
    {
        
        CGFloat contentViewX  = self.baseContentView.bounds.size.width -  [RCIM sharedRCIM].globalMessagePortraitSize.width - HeadAndContentSpacing - 10 - bubbleSize.width;
        CGRect msgContentViewFrame = self.messageContentView.frame;
        msgContentViewFrame.origin.x = contentViewX;
        msgContentViewFrame.size.width = bubbleSize.width;
        msgContentViewFrame.size.height = bubbleSize.height;
        self.messageContentView.frame = msgContentViewFrame;
        //self.messageContentView.backgroundColor  = [UIColor redColor];
        self.bubbleBGView.frame = CGRectMake(msgContentViewFrame.size.width - bubbleSize.width , 0, bubbleSize.width, bubbleSize.height);
        
        
        UIImage *image = [RCKitUtility imageNamed:@"chat_to_bg_normal"
                                         ofBundle:@"RongCloud.bundle"];
        self.bubbleBGView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8,
                                                                                        image.size.width * 0.2,
                                                                                        image.size.height * 0.2,
                                                                                        image.size.width * 0.8)];
        
        
        CGFloat minX = CGRectGetMinX(self.bubbleBGView.frame);
        CGFloat avatarHeight = bubbleSize.height - 8 * 2;
        self.avatarView.frame = CGRectMake(minX + 8, 8, avatarHeight, avatarHeight);
        
        CGFloat maxX = CGRectGetMaxX(self.avatarView.frame);
        CGFloat maxY = CGRectGetMaxY(self.avatarView.frame);
        self.nickNameLabel.frame = CGRectMake(maxX + 10, 8, 100, 21);
        //self.nickNameLabel.backgroundColor = [UIColor blueColor];
        
        self.titleLabel.frame = CGRectMake(maxX + 10, maxY - 21, 100, 21);
        
        CCBusinessCardMessage* bussionCardMessage = (CCBusinessCardMessage*)model.content;
        self.nickNameLabel.text = bussionCardMessage.nickName;
        self.titleLabel.text = bussionCardMessage.title;
        self.avatarView.yy_imageURL = [NSURL URLWithString:bussionCardMessage.avatarURL];
    }
    

}


+ (CGSize)sizeForMessageModel:(RCMessageModel *)model withCollectionViewWidth:(CGFloat)collectionViewWidth referenceExtraHeight:(CGFloat)extraHeight
{
    ///CGSizeMake(180, 60);
    CGFloat __messagecontentview_height = 60;
    __messagecontentview_height += extraHeight;
    
    return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

+ (CGSize)getBubbleSize{
    return  CGSizeMake(180, 60);
}


#pragma mark - Target Action
- (void)tapAction:(UITapGestureRecognizer*)tap
{
    [self.delegate didTapMessageCell:self.model];
    ///NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    UIMenuController* mc = [UIMenuController sharedMenuController];
    mc.menuItems = @[[[UIMenuItem alloc] initWithTitle:@"hehe" action:@selector(hehe)]];
    mc.menuVisible = YES;
}


- (void)longPress:(UILongPressGestureRecognizer*)longGesture
{
    [self.delegate didLongTouchMessageCell:self.model inView:self.bubbleBGView];
}

- (void)hehe{
    
}

@end
