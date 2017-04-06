//
//  CCUserInfoViewController.m
//  CloudChat
//
//  Created by birney on 2017/4/6.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCUserInfoViewController.h"
#import <YYWebImage/YYWebImage.h>

@interface CCUserInfoViewController ()
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *portraitView;

@end

@implementation CCUserInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.portraitView.yy_imageURL = [NSURL URLWithString:self.portraitUrl];
}



@end
