//
//  CCChatViewController.m
//  CloudChat
//
//  Created by birney on 2017/3/29.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCChatViewController.h"
#import "CCCustomerEmoticonTab.h"
#import "CCBusinessCardMessage.h"
#import "CCBusinessCardCell.h"
#import "CCUserTableViewController.h"

///#define PLUGIN_BOARD_ITEM_FILE_TAG 20001

static const NSInteger PLUGIN_BOARD_ITEM_CARD_TAG =  3000;

@interface CCChatViewController ()

@end

@implementation CCChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.conversationMessageCollectionView.backgroundColor = [UIColor clearColor];
    ///self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG"]];
    
    self.displayConversationTypeArray = @[@(ConversationType_PRIVATE)];
    ///self.enableUnreadMessageIcon = YES;
    
    
    /// 添加扩展功能
    UIImage* fileImage = [RCKitUtility imageNamed:@"actionbar_file_icon"
                                         ofBundle:@"RongCloud.bundle"];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:fileImage title:@"文件" tag:PLUGIN_BOARD_ITEM_FILE_TAG];
    
    
    
    UIImage* commnetImage= [RCKitUtility imageNamed:@"Comment" ofBundle:@"RongCloud.bundle"];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:commnetImage title:@"名片" tag:PLUGIN_BOARD_ITEM_CARD_TAG];
    
    /// 添加表情扩展
    CCCustomerEmoticonTab* addTab = [CCCustomerEmoticonTab new];
    addTab.identify = @"0";
    addTab.image = [RCKitUtility imageNamed:@"add"
                    
                                   ofBundle:@"RongCloud.bundle"];;
    addTab.pageCount = 1;
    
    [self.chatSessionInputBarControl.emojiBoardView addExtensionEmojiTab:addTab];
    
    
    
    ///注册地定义消息于cell
    [self registerClass:[CCBusinessCardCell class] forMessageClass:[CCBusinessCardMessage class]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.defaultInputType = RCChatSessionInputBarInputExtention;
    self.defaultInputType = RCChatSessionInputBarInputText;
    [self.chatSessionInputBarControl setInputBarType:RCChatSessionInputBarControlDefaultType style:RC_CHAT_INPUT_BAR_STYLE_SWITCH_CONTAINER_EXTENTION];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"segue_show_user_list"]){
        UINavigationController* navc = (UINavigationController*)segue.destinationViewController;
        CCUserTableViewController* utc = (CCUserTableViewController*)navc.viewControllers.firstObject;
        __weak typeof(self)  weakSelf = self;
        utc.selectBlock = ^(NSString *nickName, NSString *title, NSString *url) {
            CCBusinessCardMessage* cardMessage = [CCBusinessCardMessage new];
            cardMessage.nickName = nickName;
            cardMessage.title = title;
            cardMessage.avatarURL = url;
            
            [weakSelf sendMessage:cardMessage pushContent:nil];
        };
    }
}


#pragma mark - OVerride

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isMemberOfClass:[RCTextMessageCell class]]) {
        RCTextMessageCell* textMessageCell = (RCTextMessageCell*)cell;
        UILabel* textMsgLable = (UILabel*) textMessageCell.textLabel;
        textMsgLable.textColor = [UIColor redColor];
    }
}

- (void)didTapMessageCell:(RCMessageModel *)model
{
    [super didTapMessageCell:model];
}

- (void)didLongTouchMessageCell:(RCMessageModel *)model inView:(UIView *)view
{
    [super didLongTouchMessageCell:model inView:view];
}

- (void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model
{
    [super didTapUrlInMessageCell:url model:model];
}

- (void)didTapCellPortrait:(NSString *)userId
{
    ///[super didTapCellPortrait:userId];
    [self performSegueWithIdentifier:@"segue_show_user_info" sender:nil];
}

- (void)didLongPressCellPortrait:(NSString *)userId
{
}


- (void)sendMessage:(RCMessageContent *)messageContent pushContent:(NSString *)pushContent
{
    [super sendMessage:messageContent pushContent:@"你收到一条消息"];
    

    
}

- (void)resendMessage:(RCMessageContent *)messageContent
{
    NSLog(@"resendMessage");
   // [self sendMessage:messageContent pushContent:@"您又收到一条消息"];
    [super resendMessage:messageContent];
}

- (RCMessageContent*)willSendMessage:(RCMessageContent *)messageContent
{
    NSLog(@"willSendMessage");
    return messageContent;
}

- (void)didSendMessage:(NSInteger)status content:(RCMessageContent *)messageContent
{
    NSLog(@"didSendMessage");
    
    
//    ///消息发送完成后，追加一条信息
//    
//    bool saveToDB = NO;
//    RCMessage* rcMessage = nil;
//    RCInformationNotificationMessage* wariningMessage = [RCInformationNotificationMessage notificationWithMessage:@"May i have your attention please! I have a very important announcement make" extra:nil];
//    if (saveToDB) {
//        rcMessage = [[RCIMClient sharedRCIMClient] insertOutgoingMessage:self.conversationType targetId:self.targetId sentStatus:SentStatus_SENT content:wariningMessage];
//    }else{
//        rcMessage = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:MessageDirection_SEND messageId:-1 content:wariningMessage];
//    }
//    [self appendAndDisplayMessage:rcMessage];
}


//- (RCMessage*)willAppendAndDisplayMessage:(RCMessage *)message{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
//    return nil;
//}

#pragma mark - 

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    if(PLUGIN_BOARD_ITEM_CARD_TAG == tag){
        [self performSegueWithIdentifier:@"segue_show_user_list" sender:nil];
    }
}

@end
