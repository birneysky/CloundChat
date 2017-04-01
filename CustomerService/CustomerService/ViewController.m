//
//  ViewController.m
//  CustomerService
//
//  Created by birney on 2017/4/1.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "ViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "CCBusinessCardMessage.h"

@interface ViewController () <RCIMClientReceiveMessageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ////// 设置消息接收监听
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    
    /// 
    //[[RCIM sharedRCIM] registerMessageType:[CCBusinessCardMessage class]];
    [[RCIMClient sharedRCIMClient] registerMessageType:[CCBusinessCardMessage class]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - target action

- (IBAction)loginBtnAction:(UIButton *)sender {
    
    if ([sender.currentTitle isEqualToString:@"Login"]) {
        ////与RongCloudServer  建立连接
        [[RCIMClient sharedRCIMClient] connectWithToken:@"LB00zAhji5uSDj/4i5g59QuQQ4rxOA/w86vdIdQOP2x4fs9Pm6C0JaHXx2ZFDa9ltt2eWwXTpZ9atnzWxe83MQ==" success:^(NSString *userId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setTitle:@"Logout" forState:UIControlStateNormal];
            });
            NSLog(@"登陆成功啦，我的用户id是 %@",userId);
        } error:^(RCConnectErrorCode status) {
            NSLog(@"登陆失败");
        } tokenIncorrect:^{
            NSLog(@"登陆失败访问令牌不正确");
        }];
    }
    else{
         /// 断开链接 
        [[RCIMClient sharedRCIMClient] disconnect];
        [sender setTitle:@"Login" forState:UIControlStateNormal];
    }
    
}

- (IBAction)sendMsgAction:(UIBarButtonItem *)sender {
    
    ///  发送文本消息 私聊
    /// 构建消息对象
    for (int i = 0; i < 5; i ++) {
        RCTextMessage* textMsg = [RCTextMessage messageWithContent:[NSString stringWithFormat:@"test: %ld %i",(long)time(NULL),i]];
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:@"user1" content:textMsg pushContent:nil pushData:nil success:^(long messageId) {
            NSLog(@"文本消息发送成功 imessageId: %ld",messageId);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"文本消息发送失败 errorcode: %ld, messageId: %ld",(long)nErrorCode,messageId);
        }];
    }
    
    sleep(1);
    /// 发送图片消息 群聊
    
    for (int i = 0; i < 5; i++) {
        RCImageMessage* imgMessage = [RCImageMessage messageWithImage:[UIImage imageNamed:@"jobs"]];
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_GROUP targetId:@"group1" content:imgMessage pushContent:nil pushData:nil success:^(long messageId) {
            NSLog(@"图片消息发送成功 imessageId: %ld",messageId);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"图片消息发送失败 errorcode: %ld, messageId: %ld",(long)nErrorCode,messageId);
        }];
    }

    ////RCVoiceMessage
    ///RCRichContentItem  公众服务图文信息条目类
    ///RCRichContentMessage
    sleep(1);
    for (int i= 0; i < 5;  i++) {
        NSString* title = [NSString stringWithFormat:@" title %d",i];
        RCRichContentMessage* richContentMessage = [RCRichContentMessage messageWithTitle:title digest:@"xxxxx" imageURL:@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=de25d952b7b7d0a27bc9039bf3d41134/024f78f0f736afc30a208a85b619ebc4b7451225.jpg" extra:nil];
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:@"user1" content:richContentMessage pushContent:nil pushData:nil success:^(long messageId) {
            NSLog(@"富文本消息发送成功 imessageId: %ld",messageId);
        } error:^(RCErrorCode nErrorCode, long messageId) {
            NSLog(@"富文本消息发送失败 errorcode: %ld, messageId: %ld",(long)nErrorCode,messageId);
        }];
        
    }
    
    sleep(1);
    /// 发送自定义消息
    
    for (int i = 0; i < 5; i++) {
        CCBusinessCardMessage* message = [CCBusinessCardMessage messageWithName:@"雷军" title:@"CEO" avatarUrl:@"http://d.hiphotos.baidu.com/baike/w%3D268%3Bg%3D0/sign=de25d952b7b7d0a27bc9039bf3d41134/024f78f0f736afc30a208a85b619ebc4b7451225.jpg"];
        [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:@"user1" content:message pushContent:nil pushData:nil success:^(long messageId) {
            NSLog(@"自定义消息消息发送成功 imessageId: %ld",messageId);
        } error:^(RCErrorCode nErrorCode, long messageId) {
             NSLog(@"自定义消息发送成功 imessageId: %ld",messageId);
        }];
    }
    
}


#pragma mark - RCIMClientReceiveMessageDelegate 

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object
{
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        NSLog(@"收到一条文本消息 id: %ld",message.messageId);
    }
    else if ([message.content isMemberOfClass:[RCImageMessage class]]){
        NSLog(@"收到一条图片消息 id: %ld",message.messageId);
    }
    else if([message.content isMemberOfClass:[RCRichContentMessage class]]){
        NSLog(@"收到一条富文本文本消息 id: %ld",message.messageId);
    }
    else if([message.content isMemberOfClass:[CCBusinessCardMessage class]]){
        NSLog(@"收到一条自定义消息 id: %ld",message.messageId);
    }
}

@end
