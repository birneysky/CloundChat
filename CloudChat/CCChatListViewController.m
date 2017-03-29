//
//  CCChatListViewController.m
//  CloudChat
//
//  Created by birney on 2017/3/28.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCChatListViewController.h"
#import "CCChatViewController.h"

@interface CCChatListViewController ()

@end

@implementation CCChatListViewController



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    
    //设置需要将哪些类型的会话在会话列表中聚合显示
    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION),
                                          @(ConversationType_GROUP)]];
    
    
    self.cellBackgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
    self.topCellBackgroundColor = [UIColor greenColor];
 
    //
    [RCIM sharedRCIM].globalMessageAvatarStyle = RC_USER_AVATAR_CYCLE;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Target Action
- (IBAction)addButtonClicked:(id)sender {
    
    CCChatViewController* cvc = [[CCChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:@"user2"];
    cvc.title = @"user2";
    [self.navigationController pushViewController:cvc animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue_show_conversation_detail"]) {
        RCConversationModel* model = sender;
        CCChatViewController* cccvc = (CCChatViewController*)segue.destinationViewController;
        cccvc.conversationType = model.conversationType;
        cccvc.targetId = model.targetId;
        RCUserInfo* userInfo = [[RCIM sharedRCIM] getUserInfoCache:model.targetId];
        cccvc.title = userInfo.name;
    }
}

#pragma mark - Override

- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segue_show_conversation_detail" sender:model];
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
