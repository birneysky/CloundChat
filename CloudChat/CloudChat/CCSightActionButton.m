//
//  RCSightActionButton.m
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/25.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightActionButton.h"


@interface CCSightActionButton ()

@property (nonatomic,strong) CAShapeLayer *ringLayer;

@property (nonatomic,strong) CAShapeLayer *progressLayer;

@property (nonatomic,strong) CAShapeLayer *centerLayer;

@property (nonatomic,strong) CADisplayLink *displayLink;

@property (nonatomic,assign) BOOL isTimeOut;

@property (nonatomic,assign) BOOL isPress;

@property (nonatomic,assign) BOOL isCancel;

@property (nonatomic,assign) CGRect ringFrame;

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) CGFloat tempInterval;

@end


@implementation CCSightActionButton


#pragma mark - Properties
- (CAShapeLayer*)ringLayer
{
  if(!_ringLayer){
    _ringLayer = [[CAShapeLayer alloc] init];
    _ringLayer.frame = self.bounds;
    _ringLayer.fillColor = [UIColor lightGrayColor].CGColor;//[UIColor colorWithRed:255 / 255.0f green:255 / 255.0f blue:255 /255.0f alpha:0.8].CGColor;
  }
  return _ringLayer;
}

- (CAShapeLayer*)progressLayer
{
  if (!_progressLayer) {
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = [UIColor colorWithRed:31/255.0f green:185 / 255.0f blue:34.0/255.0f alpha:1].CGColor;
    _progressLayer.lineWidth = 5;
    _progressLayer.lineCap = kCALineCapRound;
  }
  return _progressLayer;
}

- (CAShapeLayer*)centerLayer
{
  if (!_centerLayer) {
    _centerLayer = [[CAShapeLayer alloc] init];
    _centerLayer.frame = self.bounds;
    _centerLayer.fillColor = [UIColor whiteColor].CGColor;
  }
  return _centerLayer;
}

- (CADisplayLink*)displayLink
{
  if (!_displayLink) {
    _displayLink = [CADisplayLink displayLinkWithTarget:self  selector:@selector(linkRun)];
    _displayLink.preferredFramesPerSecond = 60;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = true;
  }
  return _displayLink;
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self.layer addSublayer:self.ringLayer];
    [self.layer addSublayer:self.centerLayer];
    self.ringFrame = CGRectZero;
    self.backgroundColor = [UIColor clearColor];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]  initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self addGestureRecognizer:tap];
  }
  return self;
}

#pragma mark - Link Selector
- (void)linkRun{
  const CGFloat interval = 25.0f;
  self.tempInterval += 1/interval;
  self.progress = self.tempInterval /interval;
  if (self.tempInterval >= interval) {
    
    [self stop];
    self.isTimeOut = true;
    [self actionTrigger:RCSightActionStateEnd];
  }
  
  [self setNeedsDisplay];
  
}

#pragma mark - Gesture Selector
- (void)longPressGesture:(UILongPressGestureRecognizer*)gesture
{
  switch (gesture.state) {
    case UIGestureRecognizerStateBegan:
    {
      self.displayLink.paused = NO;
      self.isPress = YES;
      self.isTimeOut = NO;
      [self.layer addSublayer:self.progressLayer];
      [self actionTrigger:RCSightActionStateBegin];
    }
      break;
    case UIGestureRecognizerStateChanged:
    {
      CGPoint point = [gesture locationInView:self];
      if (CGRectContainsPoint(self.ringFrame, point)) {
        self.isCancel = NO;
        [self actionTrigger:RCSightActionStateMoving];
      }
      else{
        self.isCancel = YES;
        [self actionTrigger:RCSightActionStateWillCancel];
      }
    }
      break;
    case UIGestureRecognizerStateEnded:{
      [self stop];
      if (self.isCancel) {
        [self actionTrigger:RCSightActionStateDidCancel];
      }
      else if(!self.isTimeOut){
        [self actionTrigger:RCSightActionStateEnd];
      }
      
    }
      break;
      
    default:{
      [self stop];
      self.isCancel = YES;
      [self actionTrigger:RCSightActionStateDidCancel];
    }
      break;
  }
  [self setNeedsDisplay];
}

- (void)tapGesture
{
  [self actionTrigger:RCSightActionStateBegin];
  [self actionTrigger:RCSightActionStateClick];
}

#pragma mark - override

- (void)drawRect:(CGRect)rect {
  const CGFloat width = self.bounds.size.width;
  
  CGFloat mainWith = width / 2;
  
  CGRect mainFrame = CGRectMake(mainWith/2.0f, mainWith/2.0f, mainWith, mainWith);
  
  CGRect ringFrame = CGRectInset(mainFrame, -0.3*mainWith/ 2.0f, -0.3*mainWith / 2.0f );
  self.ringFrame = ringFrame;
  if(self.isPress){
    ringFrame = CGRectInset(mainFrame, -0.4 * mainWith / 2.0f, -0.4 * mainWith / 2.0f);
  }
  
  UIBezierPath* ringPath = [UIBezierPath bezierPathWithRoundedRect:ringFrame cornerRadius:ringFrame.size.width / 2];
  self.ringLayer.path = ringPath.CGPath;
  
  if (self.isPress) {
    mainWith *= 0.8;
    mainFrame = CGRectMake((width - mainWith) / 2, (width - mainWith) / 2, mainWith, mainWith);
  }
  
  UIBezierPath *mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainWith / 2];
  self.centerLayer.path = mainPath.CGPath;
  
  if (self.isPress) {
    CGRect progressFrame = CGRectInset(ringFrame, 2.0, 2.0);
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:progressFrame.size.width / 2];
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.strokeEnd = self.progress;
  }
  
}


#pragma mark - helpers

- (void)stop
{
  self.isPress = false;
  self.tempInterval = 0.0;
  self.progress = 0;
  
  self.progressLayer.strokeEnd = 0;
  [self.progressLayer removeFromSuperlayer];
  self.displayLink.paused = YES;
  [self setNeedsDisplay];
}

- (void)actionTrigger:(RCSightActionState)state
{
  if (self.action) {
    self.action(state);
  }
}


@end
