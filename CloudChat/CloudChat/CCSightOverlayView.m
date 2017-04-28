//
//  CCSightOverlayView.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/28.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightOverlayView.h"

@interface CCSightOverlayView ()

@property (nonatomic,strong) UIToolbar *toolbar;

@end

@implementation CCSightOverlayView

#pragma mark - properties
- (UIToolbar*)toolbar
{
  if (!_toolbar) {
    _toolbar = [[UIToolbar alloc] init];
    _toolbar.tintColor = [UIColor blackColor];
  }
  return _toolbar;
}

#pragma mark - init
- (instancetype)init
{
  if (self = [super init]) {
    [self setUp];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    
  }
  return self;
}

- (void)setUp
{
  [self addSubview:self.toolbar];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  
  self.toolbar.frame = CGRectMake(0, 0, screenSize.width, screenSize.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - helper

#pragma mark - CCSightTransport

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration
{
  
}
- (void)setScrubbingTime:(NSTimeInterval)time
{
  
}
- (void)playbackComplete
{
  
}
- (void)setSubtitles:(NSArray *)subtitles
{
  
}

@end
