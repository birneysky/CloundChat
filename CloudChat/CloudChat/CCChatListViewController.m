//
//  CCChatListViewController.m
//  CloudChat
//
//  Created by birney on 2017/3/28.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCChatListViewController.h"
#import "CCChatViewController.h"
#import <RongCallKit/RongCallKit.h>

@interface CCChatListViewController ()

@end

@implementation CCChatListViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //设置需要显示哪些类型的会话
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                            @(ConversationType_DISCUSSION),
                                            @(ConversationType_CHATROOM),
                                            @(ConversationType_GROUP),
                                            @(ConversationType_APPSERVICE),
                                            @(ConversationType_SYSTEM)]];
        
        //    //设置需要将哪些类型的会话在会话列表中聚合显示
        [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                              @(ConversationType_GROUP)]];
        
        
        //self.cellBackgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
        self.topCellBackgroundColor = [UIColor greenColor];
        

    }
    return self;
}


- (instancetype)init
{
    if (self = [super init]){
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    /// 设置会话置顶
   [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_GROUP targetId:@"group1" isTop:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self.conversationListTableView reloadData];
  
}

#pragma mark - Target Action
- (IBAction)addButtonClicked:(id)sender {
    
//    CCChatViewController* cvc = [[CCChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:@"user2"];
//    cvc.title = @"user2";
//    [self.navigationController pushViewController:cvc animated:YES];
  

  //// 创建讨论组
  /// @[@"user0",@"user1",@"user2",@"user3",@"user4"]
  [[RCIMClient sharedRCIMClient] createDiscussion:@"dicussion1" userIdList:@[@"user1",@"user2"] success:^(RCDiscussion *discussion) {
    NSLog(@"创建讨论组成功 %@",discussion.discussionId);
  } error:^(RCErrorCode status) {
    NSLog(@"创建讨论组失败");
  }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    RCConversationModel* model = sender;
    if ([segue.identifier isEqualToString:@"segue_show_conversation_detail"] ||
        [segue.identifier isEqualToString:@"segue_show_group_conversation"]) {
        CCChatViewController* cccvc = (CCChatViewController*)segue.destinationViewController;
        cccvc.conversationType = model.conversationType;
        cccvc.targetId = model.targetId;
        if( ConversationType_GROUP == model.conversationType)
        {
            RCGroup* groupInfo = [[RCIM sharedRCIM] getGroupInfoCache:model.targetId];
            cccvc.title = groupInfo.groupName;
        }
        else if(ConversationType_PRIVATE == model.conversationType){
            RCUserInfo* userInfo = [[RCIM sharedRCIM] getUserInfoCache:model.targetId];
            cccvc.title = userInfo.name;
        }
    }
    else if ([segue.identifier isEqualToString:@"segue_show_sub_conversation"]){
        CCChatListViewController* cclvc = (CCChatListViewController*)segue.destinationViewController;
      
        if (ConversationType_GROUP == model.conversationType) {
            cclvc.title = @"群组";
            cclvc.displayConversationTypeArray = @[@(ConversationType_GROUP)];
        }
        else if(ConversationType_DISCUSSION == model.conversationType ){
             cclvc.title = @"讨论组";
             cclvc.displayConversationTypeArray = @[@(ConversationType_DISCUSSION)];
        }
        cclvc.collectionConversationTypeArray = nil;
    }
}

#pragma mark - Override

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath
{
    if ( RC_CONVERSATION_MODEL_TYPE_COLLECTION == conversationModelType) {
        [self performSegueWithIdentifier:@"segue_show_sub_conversation" sender:model];
    }else if(self.collectionConversationTypeArray){
         [self performSegueWithIdentifier:@"segue_show_conversation_detail" sender:model];
      
//      CCChatViewController* cccvc = [[CCChatViewController alloc] init];
//      cccvc.conversationType = model.conversationType;
//      cccvc.targetId = model.targetId;
//      [self.navigationController pushViewController:cccvc animated:YES];
//      
//      [[RCCall sharedRCCall] startSingleCall:model.targetId mediaType:RCCallMediaVideo];
    }
    else{
        [self performSegueWithIdentifier:@"segue_show_group_conversation" sender:model];
    }
}

- (void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RCConversationModel* model = self.conversationListDataSource[indexPath.row];
    if (model.conversationType == ConversationType_PRIVATE) {
        RCConversationCell* conversationCell = (RCConversationCell*)cell;
        conversationCell.conversationTitle.textColor = [UIColor blueColor];
    }
}


@end
