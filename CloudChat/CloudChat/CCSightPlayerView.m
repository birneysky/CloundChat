//
//  CCSightPlayer.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/28.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightPlayerView.h"
#import "CCSightOverlayView.h"


@interface CCSightPlayerView ()
@property (strong, nonatomic) CCSightOverlayView *overlayView;
@end

@implementation CCSightPlayerView
#pragma mark - Properties
- (CCSightOverlayView*)overlayView
{
  if (!_overlayView) {
    _overlayView = [[CCSightOverlayView alloc] init];
  }
  return _overlayView;
}


#pragma mark - override
+ (Class)layerClass {
  return [AVPlayerLayer class];
}

#pragma mark - api
- (id)initWithPlayer:(AVPlayer *)player {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.backgroundColor = [UIColor blackColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
    
    [(AVPlayerLayer *) [self layer] setPlayer:player];
    
    [self addSubview:self.overlayView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.overlayView.frame = self.bounds;
}

- (id <CCSightTransport>)transport {
  return self.overlayView;
}

@end
