 //
//  ViewController.m
//  CloudChat
//
//  Created by birney on 2017/3/28.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "ViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "AppDelegate.h"
#import "CCGroupAndUserDataSet.h"

@interface ViewController ()

@end

static NSString* const token = @"Ig3lY+675yPP38oHrJeGwguQQ4rxOA/w86vdIdQOP2x4fs9Pm6C0Jek1Kmgvvc9t7e5Lv3xroX95QRyoYlytAA==";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /*Ig3lY+675yPP38oHrJeGwguQQ4rxOA/w86vdIdQOP2x4fs9Pm6C0Jek1Kmgvvc9t7e5Lv3xroX95QRyoYlytAA==*/
    /*AhnrTAaoylpkLmMyGisF8QuQQ4rxOA/w86vdIdQOP2x4fs9Pm6C0JcRs4uG7Qg4dVYMj0hxhnY95QRyoYlytAA==*/
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target Action

- (IBAction)loginBtnClicked:(UIButton *)sender {
    
    ///connectionWithToken 成功的回调不在主线程
    CCGroupAndUserDataSet* defaultSet = [CCGroupAndUserDataSet defalutSet];
    [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
        NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
        /// 设置用户或者组信息上报代理
        [RCIM sharedRCIM].userInfoDataSource = defaultSet;
        [RCIM sharedRCIM].groupInfoDataSource = defaultSet;
        [RCIM sharedRCIM].groupUserInfoDataSource = defaultSet;
        [RCIM sharedRCIM].groupMemberDataSource = defaultSet;
        ///设置消息监听代理
        [RCIM sharedRCIM].receiveMessageDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segue_show_conversation_list" sender:sender];
        });
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%ld", (long)status);
    } tokenIncorrect:^{
         NSLog(@"token错误");
    }];
}


@end
