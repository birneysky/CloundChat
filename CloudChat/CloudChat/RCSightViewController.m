//
//  RCSightViewController.m
//  CloudChat
//
//  Created by birneysky on 2017/4/24.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "RCSightViewController.h"
#import "RCSightView.h"

@interface RCSightViewController ()

@property (nonatomic,strong) RCSightView * sightView;

@end

@implementation RCSightViewController

#pragma mark - Properties
- (RCSightView*)sightView
{
    if (!_sightView) {
        _sightView = [[RCSightView alloc] initWithFrame:CGRectZero];
    }
    return _sightView;
}

#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.sightView];
    [self strechToSuperview:self.sightView];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
