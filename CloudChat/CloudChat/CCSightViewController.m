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
///#import "RCExtensionCommon.h"

@interface CCSightViewController () <CCSightViewDelegate>

@property (nonatomic,strong) CCSightView *sightView;

@property (nonatomic,strong) CCSightCapturer *capturer;

@property (nonatomic,strong) UIButton *switchCameraBtn;

@property (nonatomic,strong) UIImageView *stillImageView;

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

- (BOOL)prefersStatusBarHidden{
  return NO;
}

- (void)showStillImage:(UIImage*)image
{
  
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - RCSightViewDelegate
- (void)cancelVideoPreview
{
   [self.capturer startRunning];
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - target action

- (void)switchCameraAction:(UIButton*)sender
{
  [self.capturer switchCamera];
}

@end
