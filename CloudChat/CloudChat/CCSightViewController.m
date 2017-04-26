//
//  RCSightViewController.m
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightViewController.h"
#import "CCSightView.h"
#import "CCSightCapturer.h"
#import "CCSightActionButton.h"
///#import "RCExtensionCommon.h"

@interface CCSightViewController () <CCSightViewDelegate>

@property (nonatomic,strong) CCSightView *sightView;

@property (nonatomic,strong) CCSightCapturer *capturer;

@property (nonatomic,strong) UIButton *switchCameraBtn;

@property (nonatomic,strong) UIButton *dismissBtn;

@property (nonatomic,strong) UIImageView *stillImageView;

@property (nonatomic,strong) CCSightActionButton *actionButton;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) UIButton *okBtn;

@end

@implementation CCSightViewController

#pragma mark - Properties
- (CCSightView*)sightView
{
  if (!_sightView) {
    _sightView = [[CCSightView alloc] initWithFrame:CGRectZero];
  }
  return _sightView;
}

- (CCSightCapturer*)capturer
{
  if (!_capturer) {
    _capturer = [[CCSightCapturer alloc] initWithVideoPreviewPlayer:self.sightView.previewLayer];
  }
  return _capturer;
}

- (UIImageView*)stillImageView
{
    if (!_stillImageView) {
        _stillImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _stillImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _stillImageView;
}

- (UIButton*)switchCameraBtn
{
  if (!_switchCameraBtn) {
    _switchCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
    [_switchCameraBtn setTitle:@"⌘" forState:UIControlStateNormal];
    ///[_switchCameraBtn setImage:RCExtensionResourceImage(@"sight_camera_switch") forState:UIControlStateNormal];
    [_switchCameraBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
    [_switchCameraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _switchCameraBtn.backgroundColor = [UIColor clearColor];
    [_switchCameraBtn addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _switchCameraBtn;
}


- (CCSightActionButton*)actionButton
{
    if (!_actionButton) {
        _actionButton = [[CCSightActionButton alloc] initWithFrame:CGRectMake(0, 0, ActionBtnSize, ActionBtnSize)];
    }
    return _actionButton;
}

- (UIButton*)dismissBtn
{
    if (!_dismissBtn) {
        _dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
        [_dismissBtn setTitle:@"⌵" forState:UIControlStateNormal];
        ///[_dismissBtn setImage:RCExtensionResourceImage(@"icon_sight_close") forState:UIControlStateNormal];
        [_dismissBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_dismissBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _dismissBtn.backgroundColor = [UIColor clearColor];
        [_dismissBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UIButton*)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, OKBtnSize, OKBtnSize)];
        [_cancelBtn setTitle:@"↩︎" forState:UIControlStateNormal];
        //[_cancelBtn setImage:RCExtensionResourceImage(@"sight_preview_cancel") forState:UIControlStateNormal];
        
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
        ///[_okBtn setImage:RCExtensionResourceImage(@"sight_preview_done") forState:UIControlStateNormal];
        [_okBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_okBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _okBtn.layer.cornerRadius = OKBtnSize / 2;
        _okBtn.backgroundColor =  [UIColor whiteColor];
        [_okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    }
     return _okBtn;
}

#pragma mark - Init
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  self.sightView.delegate = self;
  
  [self.view addSubview:self.sightView];
  [self strechToSuperview:self.sightView];
  [self.capturer startRunning];
  
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  self.switchCameraBtn.center = CGPointMake(screenSize.width - OKBtnSize / 2, 20 + OKBtnSize / 2);
  [self.view addSubview:self.switchCameraBtn];
  
  __weak typeof(self) weakSelf = self;
  self.capturer.captureStillImageCompletionHandler = ^(UIImage *image) {
    [weakSelf showStillImage:image];
  };
    
    [self.view addSubview:self.stillImageView];
    [self strechToSuperview:self.stillImageView];
    self.stillImageView.hidden = YES;
 
    [self.actionButton setAction:^ (RCSightActionState state){
        [weakSelf handleActionState:state];
    }];
    
    [self.view addSubview:self.dismissBtn];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.okBtn];
    
    [self.view addSubview:self.actionButton];
    
    self.actionButton.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
    self.cancelBtn.center = self.actionButton.center; //CGPointMake(screenSize.width / 2 / 2 - ActionBtnSize  / 2, screenSize.height - ActionBtnSize - BottomSpace);
    self.okBtn.center = self.actionButton.center;//CGPointMake(screenSize.width / 2 + 100, screenSize.height - ActionBtnSize - BottomSpace);
    self.dismissBtn.center = CGPointMake(self.actionButton.center.x - 100, self.actionButton.center.y);
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - override
- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Helpers

- (void)strechToSuperview:(UIView*)view
{
  view.translatesAutoresizingMaskIntoConstraints = NO;
  NSArray* formats = @[@"H:|[view]|",@"V:|[view]|"];
  for(NSString* each in formats){
    NSArray* constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:each
                                            options:0
                                            metrics:nil
                                              views:@{@"view":view}];
    [self.view addConstraints:constraints];
  }
}

- (void)showStillImage:(UIImage*)image
{
  dispatch_async(dispatch_get_main_queue(), ^{
      self.stillImageView.image = image;
      self.stillImageView.hidden = NO;
  });
}

- (void)handleActionState:(RCSightActionState) states
{
    switch (states) {
        case RCSightActionStateBegin:
            self.dismissBtn.hidden = YES;
            break;
        case RCSightActionStateClick:
            [self.capturer captureStillImage];
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

#pragma mark - RCSightViewDelegate

- (void)cancelVideoPreview
{
   //[self.capturer startRunning];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - target action

- (void)switchCameraAction:(UIButton*)sender
{
  [self.capturer switchCamera];
}


- (void)dismissAction:(UIButton*)sender
{
    [self.capturer stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)cancelAction:(UIButton*)sender
{
    [UIView animateWithDuration:AnimateDuration animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.cancelBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
        self.okBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
    } completion:^(BOOL finished) {
        self.actionButton.hidden = NO;
        self.dismissBtn.hidden = NO;
        self.stillImageView.hidden = YES;
    }];
}

- (void)okAction:(UIButton*)sender
{
    
}


@end
