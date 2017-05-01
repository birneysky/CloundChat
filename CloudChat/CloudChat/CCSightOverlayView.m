//
//  CCSightOverlayView.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/28.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightOverlayView.h"


@interface CCSightOverlayView ()

@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) UIButton *closeBtn;

@property (nonatomic,strong) UILabel *currentTimeLabel;

@property (nonatomic,strong) UILabel *endTimeLabel;

@property (nonatomic,strong) UISlider *slider;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) NSLayoutConstraint *bottomConstraint;

@property (nonatomic,strong) NSLayoutConstraint *topConstraint;

@end

@implementation CCSightOverlayView

#pragma mark - properties

- (UIButton*)playBtn
{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"player_star_button"] forState:UIControlStateNormal];
    }
    return _playBtn;
}

- (UIButton*)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"sight_top_toolbar_close"] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (UISlider*)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [_slider addTarget:self action:@selector(hidePopupUI) forControlEvents:UIControlEventTouchUpInside];
//        [_slider addTarget:self action:@selector(unhidePopupUI) forControlEvents:UIControlEventTouchDown]
    }
    return _slider;
}

- (UILabel*)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

- (UILabel*)endTimeLabel
{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.textColor = [UIColor whiteColor];
        _endTimeLabel.text = @"10:00";
    }
    return _endTimeLabel;
}

- (UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor redColor];///[UIColor colorWithPatternImage:[UIImage imageNamed:@"playerShadowTop"]];
        [self constrainView:_topView toSize:44 direction:CCSightLayoutDirectionVertical];
        
        [self constrainView:self.closeBtn toSize:44 direction:CCSightLayoutDirectionHorizontal];
        [_topView addSubview:self.closeBtn];
        
        [self constraintAlignSuperView:self.closeBtn alignSpace:0 AlignMent:CCSightLayoutAlignTop];
        [self constraintAlignSuperView:self.closeBtn alignSpace:0 AlignMent:CCSightLayoutAlignLeading];
        [self constraintAlignSuperView:self.closeBtn alignSpace:0 AlignMent:CCSightLayoutAlignBottom];
    }
    return _topView;
}



- (UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor redColor]; ///[UIColor colorWithPatternImage:[UIImage imageNamed:@"playerShadowBottom"]];;;
        [self constrainView:_bottomView toSize:44 direction:CCSightLayoutDirectionVertical];
        
        
        [self constrainView:self.playBtn toSize:44 direction:CCSightLayoutDirectionHorizontal];
        [_bottomView addSubview:self.playBtn];
        
        [self constraintAlignSuperView:self.playBtn alignSpace:0 AlignMent:CCSightLayoutAlignTop];
        [self constraintAlignSuperView:self.playBtn alignSpace:0 AlignMent:CCSightLayoutAlignLeading];
        [self constraintAlignSuperView:self.playBtn alignSpace:0 AlignMent:CCSightLayoutAlignBottom];
        
  
        [self constrainView:self.currentTimeLabel toSize:50 direction:CCSightLayoutDirectionHorizontal];
        [_bottomView addSubview:self.currentTimeLabel];
        
        [self constraintCenterYInSuperview:self.currentTimeLabel];
        [self constraintView:self.playBtn toView:self.currentTimeLabel horizontalSpace:8];
        
        
        [self constrainView:self.endTimeLabel toSize:50 direction:CCSightLayoutDirectionHorizontal];
        [_bottomView addSubview:self.endTimeLabel];
        [self constraintCenterYInSuperview:self.endTimeLabel];
        [self constraintAlignSuperView:self.endTimeLabel alignSpace:0 AlignMent:CCSightLayoutAlignTrailing];
        
    
        [_bottomView addSubview:self.slider];
        [self constraintCenterYInSuperview:self.slider];
        [self constraintView:self.currentTimeLabel toView:self.slider horizontalSpace:8];
        [self constraintView:self.slider toView:self.endTimeLabel horizontalSpace:8];
    }
    return _bottomView;
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
    self.backgroundColor = [UIColor clearColor];

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self installHorizontalFlexibleConstraintsForView:self.topView];
    self.topConstraint = [self constraintAlignSuperView:self.topView alignSpace:0 AlignMent:CCSightLayoutAlignTop];

    [self installHorizontalFlexibleConstraintsForView:self.bottomView];
    self.bottomConstraint = [self constraintAlignSuperView:self.bottomView alignSpace:0 AlignMent:CCSightLayoutAlignBottom];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - target action
- (void)play
{
    
}

- (void)sliderValueChanged:(UISlider*)slider
{
     [self setScrubbingTime:slider.value];
    [self.delegate scrubbedToTime:slider.value];
}

#pragma mark - helper

- (NSString *)formatSeconds:(NSInteger)value {
    NSInteger seconds = value % 60;
    NSInteger minutes = value / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long) minutes, (long) seconds];
}

-(UIImage*)imageWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage*  image = UIGraphicsGetImageFromCurrentImageContext(); //据说该方法返回的对象是autorelease的
    UIGraphicsEndImageContext();
    return image;
}

- (void)installHorizontalFlexibleConstraintsForView:(UIView*)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *horizontalFromat = @"H:|[view]|";
    NSArray *horizontalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:horizontalFromat
                                                options:0
                                                metrics:nil
                                                  views:@{@"view":view}];
    [self addConstraints:horizontalConstraints];
}

typedef NS_ENUM(NSInteger,CCSightLayoutDirection){
    CCSightLayoutDirectionHorizontal = 0,
    CCSightLayoutDirectionVertical,
};

- (void)constrainView:(UIView*)view toSize:(CGFloat)size direction:(CCSightLayoutDirection)direction;
{
    NSString *axisString = direction == CCSightLayoutDirectionHorizontal ? @"H:" : @"V:";
    NSString *formatString = [NSString stringWithFormat:@"%@[view(==size)]",axisString];
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSDictionary* metrics = @{@"size":@(size)};
    NSArray* constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:formatString
                            options:0
                            metrics:metrics
                              views:bindings];
    [view addConstraints:constraints];
}



- (void)constraintView:(UIView*)leftview toView:(UIView*)rightView horizontalSpace:(CGFloat)space
{
    leftview.translatesAutoresizingMaskIntoConstraints = NO;
    rightView.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *formatString = @"H:[left]-space-[right]";
    NSDictionary *bindings = @{@"left":leftview,@"right":rightView};
    NSDictionary *metrics = @{@"space":@(space)};
    NSArray<NSLayoutConstraint*>* constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                options:0
                                                metrics:metrics
                                                  views:bindings];
    constraints.firstObject.priority = NSURLSessionTaskPriorityHigh;
    [leftview.superview addConstraints:constraints];
//    for(NSLayoutConstraint* each in constraints){
//        [leftview.superview addConstraint:each];
//    }


//    NSLayoutConstraint* constraint =
//        [NSLayoutConstraint constraintWithItem:leftview
//                                     attribute:NSLayoutAttributeRight
//                                     relatedBy:NSLayoutRelationEqual
//                                        toItem:rightView
//                                     attribute:NSLayoutAttributeLeft
//                                    multiplier:1.0f
//                                      constant:space];
//    //[constraint install];
//    [self addConstraint:constraint];
}

- (void)constraintCenterYInSuperview:(UIView*)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view.superview attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
    [view.superview addConstraint:constraint];
}

typedef NS_ENUM(NSInteger,CCSightLayoutAlignMent){
    CCSightLayoutAlignLeading = 0,
    CCSightLayoutAlignTrailing,
    CCSightLayoutAlignTop,
    CCSightLayoutAlignBottom,
};

- (NSLayoutConstraint*)constraintAlignSuperView:(UIView*)view alignSpace:(CGFloat)space AlignMent:(CCSightLayoutAlignMent)align
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSString* formatString = nil;
    if (CCSightLayoutAlignLeading == align) {
        formatString = @"H:|-space-[view]";
    }
    else if (CCSightLayoutAlignTrailing == align){
        formatString = @"H:[view]-space-|";
    }
    else if (CCSightLayoutAlignTop == align){
        formatString = @"V:|-space-[view]";
    }
    else if (CCSightLayoutAlignBottom == align){
        formatString = @"V:[view]-space-|";
    }
    NSDictionary *bindings = @{@"view":view};
    NSDictionary *metrics = @{@"space":@(space)};
    NSArray* constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:formatString
                                                options:0
                                                metrics:metrics
                                                  views:bindings];
    [view.superview addConstraints:constraints];
    return constraints.firstObject;
}

#pragma mark - CCSightTransport

- (void)setControlBarHidden:(BOOL)hidden
{
    if (hidden) {
        self.topConstraint.constant = -44;
        self.bottomConstraint.constant = -44;
        [self updateConstraintsIfNeeded];
    }
}

- (void)setCurrentTime:(NSTimeInterval)time duration:(NSTimeInterval)duration
{
  
}
- (void)setScrubbingTime:(NSTimeInterval)time
{
  self.currentTimeLabel.text = [self formatSeconds:time];
}
- (void)playbackComplete
{
  
}
- (void)setSubtitles:(NSArray *)subtitles
{
  
}

@end
