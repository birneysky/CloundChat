//
//  RCSightViewController.m
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCSightViewController.h"
#import "RCSightView1.h"
#import "RCSightCapturer1.h"

@interface RCSightViewController () <RCSightViewDelegate>

@property (nonatomic,strong) RCSightView1 * sightView;

@property (nonatomic,strong) RCSightCapturer1 *capturer;

@end

@implementation RCSightViewController

#pragma mark - Properties
- (RCSightView1*)sightView
{
    if (!_sightView) {
        _sightView = [[RCSightView1 alloc] initWithFrame:CGRectZero];
    }
    return _sightView;
}

- (RCSightCapturer1*)capturer
{
    if (!_capturer) {
        _capturer = [[RCSightCapturer1 alloc] initWithVideoPreviewPlayer:self.sightView.previewLayer];
    }
    return _capturer;
}

#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sightView.delegate = self;
    
    [self.view addSubview:self.sightView];
    [self strechToSuperview:self.sightView];
    [self.capturer startRunning];
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarHidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [UIApplication sharedApplication].statusBarHidden = NO;
//}

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
    return YES;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
