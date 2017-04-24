//
//  RCDCustomerEmoticonTab.m
//  CloudChat
//
//  Created by birneysky on 2017/3/29.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCCustomerEmoticonTab.h"
#import "CCEmojiButton.h"
#import "CCEmojiPreview.h"
#import "CCEmojiNameManager.h"

@interface CCCustomerEmoticonTab ()


@property (nonatomic,strong) CCEmojiPreview* emojiPreview;

@property (nonatomic,strong) NSMutableArray<UIView*>* cacheViews;

@end


@implementation CCCustomerEmoticonTab

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Properties
- (CCEmojiPreview*)emojiPreview
{
    if (!_emojiPreview) {
        _emojiPreview = [CCEmojiPreview  emojiPreview];
    }
    return _emojiPreview;
}

- (NSMutableArray<UIView*>*)cacheViews
{
    if (!_cacheViews) {
        _cacheViews = [NSMutableArray new];
    }
    return _cacheViews;
}

#pragma mark - RCEmoticonTabSource
-(UIView *)loadEmoticonView:(NSString *)identify index:(int)index;
{
    UIView *view = nil;
    if (index >= self.cacheViews.count) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 186)];
        [self.cacheViews addObject:view];
    }
    else{
        view = self.cacheViews[index];
    }
    
    
    view.backgroundColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248 / 255.0f alpha:1];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressView:)];
    [view addGestureRecognizer:longPressGesture];
  
    [self configureView:view index:index];
    
    return view;
}


#pragma mark - Helper

- (void)configureView:(UIView*)view  index:(NSInteger)index{
    ///NSString * filePath = [[NSBundle mainBundle] pathForResource:@"CCEmojiNames" ofType:@"plist"];
    ///NSArray*  emojiStringArray = [NSArray arrayWithContentsOfFile:filePath];
    
    CGFloat panelWith = view.bounds.size.width;
    CGFloat panelHeight = view.bounds.size.height;
    
    CGFloat emojiWidth = 48.0f;
    CGFloat emojiHeight = 48.0f;
    
    NSUInteger rowCount = panelHeight / (emojiWidth );
    NSUInteger columnCount = panelWith / (emojiWidth );
    NSUInteger numberPerPage = rowCount * columnCount;
    
    CGFloat xOffset = (panelWith - columnCount * emojiWidth) / 2;
    CGFloat yOffset = (panelHeight - rowCount * emojiHeight) / 2;

    
    NSString* expressionBundlePath = [[NSBundle mainBundle] pathForResource:@"CCEmoji" ofType:@"bundle"];
    NSUInteger startIndex = numberPerPage * index;
    ///int endIndex = numberPerPage * index + numberPerPage;
    
    for (int i = 0; i < numberPerPage ; i++) {
        NSUInteger rowIndex = (i%numberPerPage) / columnCount;
        NSUInteger columnIndex = i % columnCount;
        
        CGRect frame = CGRectMake( columnIndex * emojiWidth + xOffset, rowIndex * emojiHeight + yOffset, emojiWidth, emojiHeight);
        
        CCEmojiButton* button = [CCEmojiButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        NSString* imageName = [NSString stringWithFormat:@"Expression_%lu",i + startIndex];
        NSString* imagePathName = [expressionBundlePath stringByAppendingPathComponent:imageName];
        button.tag = i + startIndex;
        [button setImage:[UIImage imageNamed:imagePathName] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(faceClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
    }
}


- (UIButton*)enumButtonWithLocation:(CGPoint)point inView:(UIView*)view
{
    NSArray<UIButton*>* emojiButtons = view.subviews;
    __block UIButton* touchButton = nil;
    [emojiButtons  enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, point)) {
            touchButton = obj;
            *stop = YES;
        }
    }];
    return touchButton;
}

#pragma mark -  Target Action
- (void)faceClicked:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(factButtonClickedAtIndex:)]) {
        [self.delegate factButtonClickedAtIndex:button.tag];
    }
}



#pragma mark -  Gesture Action
- (void)longPressView:(UILongPressGestureRecognizer*)gesture
{
    
    CGPoint touchPoint = [gesture locationInView:gesture.view];
    UIButton* touchButton = [self enumButtonWithLocation:touchPoint inView:gesture.view];
    NSLog(@"gesture state %ld",(long)gesture.state);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (touchButton) {
                CCEmojiNameManager* emojiManager = [CCEmojiNameManager defaultManager];
                [self.emojiPreview setPreviewImage:touchButton.currentImage];
                [self.emojiPreview setEmojiName:[emojiManager nameAtIndex:touchButton.tag]];
            }
            [self.emojiPreview showFromView:touchButton];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self.emojiPreview removeFromSuperview];
            break;
        default:
            break;
    }
}
@end
