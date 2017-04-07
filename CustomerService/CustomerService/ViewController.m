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
#import "CCNetwokKit.h"

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
        [[CCNetwokKit defaultKit] fetchTokenWithUserId:@"user2" name:@"user2" success:^(NSString *token) {
            ////与RongCloudServer  建立连接
            [[RCIMClient sharedRCIMClient] connectWithToken:token success:^(NSString *userId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setTitle:@"Logout" forState:UIControlStateNormal];
                });
                NSLog(@"登陆成功啦，我的用户id是 %@",userId);
            } error:^(RCConnectErrorCode status) {
                NSLog(@"登陆失败");
            } tokenIncorrect:^{
                NSLog(@"登陆失败访问令牌不正确");
            }];
            
        } error:^(NSError *error) {
            NSLog(@"获取token 失败 %@",error);
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
    
    /// 插入消息
    
    CCBusinessCardMessage* message = [CCBusinessCardMessage messageWithName:@"Toney" title:@"Developer" avatarUrl:@"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1855350/r_nin.gif"];
    [[RCIMClient sharedRCIMClient] insertOutgoingMessage:ConversationType_PRIVATE targetId:@"user1" sentStatus:SentStatus_SENT content:message];
    NSLog(@"插入一条消息");

}

- (IBAction)lastestMessageAction:(UIBarButtonItem *)sender {
    
     ///读取本地存储
    NSArray<RCMessage*>* messageList = [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_PRIVATE targetId:@"user1" count:100];
    [messageList enumerateObjectsUsingBlock:^(RCMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //NSData* data = obj.content.rawJSONData;
        NSString* content = nil;
        if ([obj.content isMemberOfClass:[RCTextMessage class]]) {
            RCTextMessage* textMessage = (RCTextMessage*)obj.content;
            content = textMessage.content;
        }
        else if([obj.content isMemberOfClass:[RCImageMessage class]]){
            content = @"图片消息";
        }
        else if([obj.content isMemberOfClass:[RCRichContentMessage class]]){
            RCRichContentMessage* richMessage = (RCRichContentMessage*)obj.content;
            content = [NSString stringWithFormat:@"{title:%@,digest:%@,imageURL:%@}",richMessage.title,richMessage.digest,richMessage.imageURL];
        }
        else if([obj.content isMemberOfClass:[CCBusinessCardMessage class]]){
            CCBusinessCardMessage* cardMessage = (CCBusinessCardMessage*)obj.content;
            content = [NSString stringWithFormat:@"{nickName:%@,title:%@,avatarURL:%@}",cardMessage.nickName,cardMessage.title,cardMessage.avatarURL];
        }
        NSLog(@"📩📩📩📩  messageId: %ld sendtime: %lld recvtime: %lld type: %@ content: %@",obj.messageId,obj.sentTime,obj.receivedTime,NSStringFromClass([obj.content class]),content);
    }];
}
- (IBAction)unreadCountAction:(UIBarButtonItem *)sender {
    
    int totoalCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
    NSLog(@"所有未读消息数 %d",totoalCount);
}

- (IBAction)converstationListAction:(id)sender {
    
    NSArray<RCConversation*>* array =  [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_CHATROOM),@(ConversationType_SYSTEM),@(ConversationType_DISCUSSION)]];
    [array enumerateObjectsUsingBlock:^(RCConversation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"会话类型：%lu，目标会话ID：%@",obj.conversationType,obj.targetId);
    }];
}

- (IBAction)clearUnreadAction:(id)sender {
    NSArray<RCConversation*>* array =  [[RCIMClient sharedRCIMClient] getConversationList:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_CHATROOM),@(ConversationType_SYSTEM),@(ConversationType_DISCUSSION)]];
    [array enumerateObjectsUsingBlock:^(RCConversation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[RCIMClient sharedRCIMClient] clearMessages:obj.conversationType targetId:obj.targetId];
    }];

    NSLog(@"清除消息未读数");
}
- (IBAction)specificConversationAction:(id)sender {
    RCConversation* conversation =  [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP targetId:@"group1"];
    NSLog(@"获取特定的会话 %p",conversation);
}


- (IBAction)searchMsgAction:(id)sender {
    NSLog(@"通过关键词查找消息 keyword: \"1\"");
    NSArray <RCMessage *>* array = [[RCIMClient sharedRCIMClient] searchMessages:ConversationType_PRIVATE targetId:@"user1" keyword:@"1" count:1000 startTime:0];
    [array enumerateObjectsUsingBlock:^(RCMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString* content = nil;
        if ([obj.content isMemberOfClass:[RCTextMessage class]]) {
            RCTextMessage* textMessage = (RCTextMessage*)obj.content;
            content = textMessage.content;
        }
        else if([obj.content isMemberOfClass:[RCImageMessage class]]){
            content = @"图片消息";
        }
        else if([obj.content isMemberOfClass:[RCRichContentMessage class]]){
            RCRichContentMessage* richMessage = (RCRichContentMessage*)obj.content;
            content = [NSString stringWithFormat:@"{title:%@,digest:%@,imageURL:%@}",richMessage.title,richMessage.digest,richMessage.imageURL];
        }
        else if([obj.content isMemberOfClass:[CCBusinessCardMessage class]]){
            CCBusinessCardMessage* cardMessage = (CCBusinessCardMessage*)obj.content;
            content = [NSString stringWithFormat:@"{nickName:%@,title:%@,avatarURL:%@}",cardMessage.nickName,cardMessage.title,cardMessage.avatarURL];
        }
        NSLog(@"📩📩📩📩  messageId: %ld sendtime: %lld recvtime: %lld type: %@ content: %@",obj.messageId,obj.sentTime,obj.receivedTime,NSStringFromClass([obj.content class]),content);
        
    }];
}


- (IBAction)searchConverstationAction:(id)sender {
    NSArray<RCSearchConversationResult *> * array = [[RCIMClient sharedRCIMClient]
                                                        searchConversations:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_CHATROOM)]
                                                                messageType:@[@"RCTextMessage",@"RCImageMessage",@"RCRichContentMessage",@"RCRichContentMessage"] keyword:@"1"];
    [array enumerateObjectsUsingBlock:^(RCSearchConversationResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"会话类型：%lu，目标会话ID：%@ 匹配条数: %d",obj.conversation.conversationType,obj.conversation.targetId,obj.matchCount);
    }];
}

#pragma mark - ClearConversation
- (IBAction)clearConversationAction:(id)sender {
    NSLog(@"删除指定类型的会话");
    BOOL result = [[RCIMClient sharedRCIMClient] clearConversations:@[@(ConversationType_PRIVATE),@(ConversationType_GROUP),@(ConversationType_CHATROOM),@(ConversationType_DISCUSSION)]];
    if (result) {
        NSLog(@"删除会话成功");
    }
    else{
        NSLog(@"删除会话失败");
    }
}

- (IBAction)removeSpecificConversationAction:(id)sender {
    NSLog(@"删除制定类型的会话");
    
   BOOL result =  [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_GROUP targetId:@"group1"];
    if (result) {
        NSLog(@"删除会话成功");
    }
    else{
        NSLog(@"删除会话失败");
    }

}


- (IBAction)saveDraftAction:(id)sender {
    
    BOOL result = [[RCIMClient sharedRCIMClient] saveTextMessageDraft:ConversationType_GROUP targetId:@"group1" content:@"Test Draft"];
    if (result) {
        NSLog(@"草稿保存成功");
    }
    else{
        NSLog(@"草稿保存失败");
    }
}
- (IBAction)getDraftAction:(id)sender {
    NSString* draftString = [[RCIMClient sharedRCIMClient] getTextMessageDraft:ConversationType_GROUP targetId:@"group1"];
    NSLog(@"group1's Draft is %@",draftString);
}
- (IBAction)clearDraftAction:(id)sender {
    BOOL result = [[RCIMClient sharedRCIMClient] clearTextMessageDraft:ConversationType_GROUP targetId:@"group1"];
    if (result) {
        NSLog(@"删除会话草稿成功");
    }
    else{
        NSLog(@"删除会话草稿失败");
    }
}
- (IBAction)All:(id)sender {
    RCTextMessage* textMesage = [RCTextMessage messageWithContent:@"@all test test"];
    
    textMesage.mentionedInfo = [[RCMentionedInfo alloc] initWithMentionedType:RC_Mentioned_All userIdList:nil mentionedContent:@"@all"];
    
    RCMessage* rcmsg = [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_GROUP targetId:@"group1" content:textMesage pushContent:nil pushData:nil success:^(long messageId) {
        NSLog(@"@all success");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"@all error");
    }];
    
    sleep(1);
    
    [[RCIMClient sharedRCIMClient] recallMessage:rcmsg success:^(long messageId) {
        NSLog(@"撤回消息成功");
    } error:^(RCErrorCode errorcode) {
        NSLog(@"撤回消息失败 %zi",errorcode);
    }];
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
