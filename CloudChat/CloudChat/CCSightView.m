//
//  RCSightView.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightView.h"
#import <AVFoundation/AVFoundation.h>
#import "CCSightActionButton.h"
///#import "RCExtensionCommon.h"

@interface CCSightView ()


@end

@implementation CCSightView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
      self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (AVCaptureVideoPreviewLayer*)previewLayer{
  return (AVCaptureVideoPreviewLayer*)self.layer;
}

#pragma mark - override
+ (Class)layerClass
{
  return [AVCaptureVideoPreviewLayer class];
}


@end
