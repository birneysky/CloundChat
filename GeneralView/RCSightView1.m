//
//  RCSightView.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCSightView1.h"
#import <AVFoundation/AVFoundation.h>
#import "RCSightActionButton.h"

#define ActionBtnSize 104
#define BottomSpace 10
#define OKBtnSize 60
#define AnimateDuration 0.2


@interface RCSightView1 ()



@property (nonatomic,strong) RCSightActionButton *actionButton;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) UIButton *okBtn;

@property (nonatomic,strong) UIButton *dismissBtn;

@property (nonatomic,strong) UIButton *switchCameraBtn;

@end

@implementation RCSightView1

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
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


- (void)layoutSubviews
{
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  self.actionButton.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
  self.cancelBtn.center = self.actionButton.center; //CGPointMake(screenSize.width / 2 / 2 - ActionBtnSize  / 2, screenSize.height - ActionBtnSize - BottomSpace);
  self.okBtn.center = self.actionButton.center;//CGPointMake(screenSize.width / 2 + 100, screenSize.height - ActionBtnSize - BottomSpace);
  self.dismissBtn.center = CGPointMake(self.actionButton.center.x - 100, self.actionButton.center.y);
  self.switchCameraBtn.center = CGPointMake(screenSize.width - OKBtnSize / 2, 20 + OKBtnSize / 2);
}

#pragma mark - Helper
- (void)setUp{
  self.backgroundColor = [UIColor blackColor];
  [self addSubview:self.switchCameraBtn];
  [self addSubview:self.dismissBtn];
  [self addSubview:self.cancelBtn];
  [self addSubview:self.okBtn];
  
  [self addSubview:self.actionButton];
  __weak typeof(self) weakSelf = self;
  [self.actionButton setAction:^ (RCSightActionState state){
    [weakSelf handleActionState:state];
  }];
  
  
}
#pragma mark - Properties


- (RCSightActionButton*)actionButton
{
  if (!_actionButton) {
    _actionButton = [[RCSightActionButton alloc] initWithFrame:CGRectMake(0, 0, ActionBtnSize, ActionBtnSize)];
  }
  return _actionButton;
}


- (UIButton*)cancelBtn{
  if (!_cancelBtn) {
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
    [_cancelBtn setTitle:@"↩︎" forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_cancelBtn  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cancelBtn.layer.cornerRadius = OKBtnSize / 2;
    _cancelBtn.backgroundColor =  [UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 / 255.0f alpha:0.8];
    [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelBtn;
}


- (UIButton*)okBtn{
  if (!_okBtn) {
    _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
    [_okBtn setTitle:@"✓" forState:UIControlStateNormal];
    [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_okBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    _okBtn.layer.cornerRadius = OKBtnSize / 2;
    _okBtn.backgroundColor =  [UIColor whiteColor];
  [_okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _okBtn;
}


- (UIButton*)dismissBtn
{
  if (!_dismissBtn) {
    _dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
    [_dismissBtn setTitle:@"⌵" forState:UIControlStateNormal];
    [_dismissBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_dismissBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _dismissBtn.backgroundColor = [UIColor clearColor];
    [_dismissBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _dismissBtn;
}


- (UIButton*)switchCameraBtn
{
    if (!_switchCameraBtn) {
        _switchCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
        [_switchCameraBtn setTitle:@"⌘" forState:UIControlStateNormal];
        [_switchCameraBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_switchCameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _switchCameraBtn.backgroundColor = [UIColor clearColor];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}





#pragma mark - helper
- (void)handleActionState:(RCSightActionState) states
{
  switch (states) {
    case RCSightActionStateBegin:
        self.dismissBtn.hidden = YES;
        break;
    case RCSightActionStateClick:
    case RCSightActionStateEnd:
      self.actionButton.hidden = YES;
      [self stopCapture];
      break;
      
    default:
      break;
  }
}


- (void)stopCapture
{
  [UIView animateWithDuration:AnimateDuration animations:^{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat offset = screenSize.width / 2 / 2;
    self.cancelBtn.center = CGPointMake(screenSize.width / 2 - offset, screenSize.height - ActionBtnSize - BottomSpace);
    self.okBtn.center = CGPointMake(screenSize.width / 2 + offset, screenSize.height - ActionBtnSize - BottomSpace);
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark - target action

- (void)cancelAction:(UIButton*)sender
{
  [UIView animateWithDuration:AnimateDuration animations:^{
     CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.cancelBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
    self.okBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
  } completion:^(BOOL finished) {
    self.actionButton.hidden = NO;
    self.dismissBtn.hidden = NO;
  }];
}

- (void)okAction:(UIButton*)sender
{
  
}

- (void)dismissAction:(UIButton*)sender
{
    if([self.delegate respondsToSelector:@selector(cancelVideoPreview)]){
        [self.delegate cancelVideoPreview];
    }
}


- (void)switchCameraAction:(UIButton*)sender
{
    
}
@end
