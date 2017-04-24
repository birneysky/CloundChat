//
//  RCSightView.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCSightView.h"
#import <AVFoundation/AVFoundation.h>
#import "RCSightCapturer.h"

@interface RCSightView ()

@property (nonatomic,strong) RCSightCapturer* capturer;

@end

@implementation RCSightView

#pragma mark - Properties
- (RCSightCapturer*)capturer
{
  if (!_capturer) {
    _capturer = [[RCSightCapturer alloc] initWithVideoPreviewPlayer:self.previewLayer];
  }
  return _capturer;
}

- (AVCaptureVideoPreviewLayer*)previewLayer{
  return (AVCaptureVideoPreviewLayer*)self.layer;
}

#pragma mark - override
+ (Class)layerClass
{
  return [AVCaptureVideoPreviewLayer class];
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
