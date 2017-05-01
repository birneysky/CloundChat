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
#import "CCSightPlayerController.h"
#import "CCSightRecorder.h"
#import <TargetConditionals.h>
///#import "RCExtensionCommon.h"

@interface CCSightViewController ()<CCSightRecorderDelegate,CCSightCapturerDelegate>

@property (nonatomic,strong) CCSightView *sightView;

@property (nonatomic,strong) CCSightCapturer *capturer;

@property (nonatomic,strong) UIButton *switchCameraBtn;

@property (nonatomic,strong) UIButton *dismissBtn;

@property (nonatomic,strong) UIImageView *stillImageView;

@property (nonatomic,strong) CCSightActionButton *actionButton;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) UIButton *okBtn;

@property (nonatomic,assign) BOOL isRecording;

@property (nonatomic,strong) CCSightRecorder *recorder;

@property (nonatomic,strong) CCSightPlayerController *playerController;

@property (nonatomic,strong) NSURL *outputUrl;

@property (nonatomic,strong) UIImage *sightThumbnail;

@property (nonatomic,strong) UILabel *tipsLable;

@property (nonatomic,strong) NSTimer *timer;

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
      _capturer.delegate = self;
  }
  return _capturer;
}

- (UIImageView*)stillImageView
{
  if (!_stillImageView) {
    _stillImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _stillImageView.contentMode = UIViewContentModeScaleAspectFit;
    _stillImageView.backgroundColor = [UIColor blackColor];
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
        ///[_dismissBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
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
        ///[_cancelBtn setImage:RCExtensionResourceImage(@"sight_preview_cancel") forState:UIControlStateNormal];
        
        //[_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
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
        ///[_okBtn.titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_okBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        _okBtn.layer.cornerRadius = OKBtnSize / 2;
        _okBtn.backgroundColor =  [UIColor whiteColor];
        [_okBtn addTarget:self action:@selector(okAction:) forControlEvents:UIControlEventTouchUpInside];
    }
     return _okBtn;
}


- (CCSightRecorder*)recorder
{
  if (!_recorder) {
      _recorder = [[CCSightRecorder alloc] initWithVideoSettings:self.capturer.recommendedVideoCompressionSettings
                                                   audioSettings:self.capturer.recommendedAudioCompressionSettings
                                                   dispatchQueue:self.capturer.sessionQueue];
      _recorder.delegate = self;
  }
  return _recorder;
}

- (UILabel*)tipsLable
{
    if (!_tipsLable) {
        _tipsLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 21)];
        _tipsLable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sight_label_shadow"]];
        _tipsLable.font = [UIFont systemFontOfSize:14.0f];
        _tipsLable.textAlignment = NSTextAlignmentCenter;
        _tipsLable.text = @"轻触拍照，按住摄像";
        _tipsLable.textColor = [UIColor whiteColor];
    }
    return _tipsLable;
}

#pragma mark - Init
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
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
    [self.view addSubview:self.tipsLable];
    
    self.actionButton.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
    self.cancelBtn.center = self.actionButton.center; //CGPointMake(screenSize.width / 2 / 2 - ActionBtnSize  / 2, screenSize.height - ActionBtnSize - BottomSpace);
    self.okBtn.center = self.actionButton.center;//CGPointMake(screenSize.width / 2 + 100, screenSize.height - ActionBtnSize - BottomSpace);
    self.dismissBtn.center = CGPointMake(self.actionButton.center.x - 100, self.actionButton.center.y);
    self.tipsLable.center = CGPointMake(screenSize.width / 2, self.actionButton.frame.origin.y);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self hideTipsLabel];
    
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
    return YES;
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
            [self startRecording];
            break;
        case RCSightActionStateClick:
            self.dismissBtn.hidden = YES;
#if !(TARGET_OS_SIMULATOR)
            [self.capturer captureStillImage];
#else
            [self showStillImage:nil];
#endif
            [self showOkCancelBtnWithAnimation];
            break;
        case RCSightActionStateDidCancel:
        case RCSightActionStateEnd:
            self.actionButton.hidden = YES;
            [self stopRecording];
            [self showOkCancelBtnWithAnimation];
            break;
      
        break;
      case RCSightActionStateWillCancel:
        break;
      case RCSightActionStateMoving:
        break;
        default:
        
      
            break;
    }
}

- (void)startRecording{
    if (!self.isRecording) {
        self.isRecording = YES;
#if !(TARGET_OS_SIMULATOR)
        [self.recorder prepareToRecord];
#endif
    }

}

- (void)stopRecording{
    if (self.isRecording) {
        self.isRecording = NO;
#if !(TARGET_OS_SIMULATOR)
        [self.recorder finishRecording];
#else
        [self didWriteMovieAtURL:nil];
#endif
    }
}

- (void)showOkCancelBtnWithAnimation
{

    [UIView animateWithDuration:AnimateDuration animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat offset = screenSize.width / 2 / 2;
        self.cancelBtn.center = CGPointMake(screenSize.width / 2 - offset, screenSize.height - ActionBtnSize - BottomSpace);
        self.okBtn.center = CGPointMake(screenSize.width / 2 + offset, screenSize.height - ActionBtnSize - BottomSpace);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideTipsLabel
{
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.tipsLable.hidden = YES;
        }];
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
    self.tipsLable.hidden = NO;
    [self hideTipsLabel];
    [UIView animateWithDuration:AnimateDuration animations:^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        self.cancelBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
        self.okBtn.center = CGPointMake(screenSize.width / 2, screenSize.height - ActionBtnSize - BottomSpace);
    } completion:^(BOOL finished) {
        self.actionButton.hidden = NO;
        self.dismissBtn.hidden = NO;
        self.stillImageView.hidden = YES;
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }];
}

- (void)okAction:(UIButton*)sender
{
  if (!self.stillImageView.hidden) {
    [self.capturer stopRunning];
    if ([self.delegate respondsToSelector:@selector(sightViewController:didFinishCapturingStillImage:)]) {
      [self.delegate sightViewController:self didFinishCapturingStillImage:self.stillImageView.image];
    }
  }
  else{
      [self.capturer stopRunning];
      if ([self.delegate respondsToSelector:@selector(sightViewController:didWriteSightAtURL:thumbnail:)]) {
          [self.delegate sightViewController:self didWriteSightAtURL:self.outputUrl thumbnail:self.sightThumbnail];
      }
  }
}


#pragma mark - CCSightRecorderDelegate

- (void)didWriteMovieAtURL:(NSURL *)outputURL
{
    
    self.playerController = [[CCSightPlayerController alloc] initWithURL:outputURL];
    [self.view insertSubview:self.playerController.view aboveSubview:self.stillImageView];
    [self strechToSuperview:self.playerController.view];
    self.outputUrl = outputURL;
    self.sightThumbnail = [self.playerController generateThumbnail];
}

#pragma mark - CCSightCapturerDelegate
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self.recorder processSampleBuffer:sampleBuffer];
}

@end
