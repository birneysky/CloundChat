//
//  CCChatRoomTableViewController.m
//  CloudChat
//
//  Created by birney on 2017/4/11.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCChatRoomTableViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "CCActiveWheel.h"
#import "CCChatViewController.h"

@interface CCChatRoomTableViewController ()

@property (nonatomic,copy) NSArray<NSDictionary*>* dataSource;

@end

@implementation CCChatRoomTableViewController

#pragma mark - property
- (NSArray<NSDictionary*>*)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@{@"chrmId":@"chatroom1",@"name":@"聊天室一",@"imgName":@"group_1"},
                        @{@"chrmId":@"chatroom2",@"name":@"聊天室二",@"imgName":@"group_2"},
                        @{@"chrmId":@"chatroom3",@"name":@"聊天室三",@"imgName":@"group_3"},
                        @{@"chrmId":@"chatroom4",@"name":@"聊天室四",@"imgName":@"group_4"}];
    }
    return _dataSource;
}

#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"聊天室";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscoverCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary* chatRoom = self.dataSource[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:chatRoom[@"imgName"]];
    cell.textLabel.text = chatRoom[@"name"];
    

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* chatRoom = self.dataSource[indexPath.row];
    
    [CCActiveWheel showHUDAddedTo:self.view].processString = @"正在加入聊天室";
    [[RCIMClient sharedRCIMClient] joinChatRoom:chatRoom[@"chrmId"] messageCount:50 success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCActiveWheel dismissForView:self.view];
            [self performSegueWithIdentifier:@"segue_show_conversation_detail" sender:indexPath];
        });
    } error:^(RCErrorCode status) {
        [CCActiveWheel dismissViewDelay:2 forView:self.view warningText:@"加入失败"];
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"segue_show_conversation_detail"]){
        CCChatViewController* cvc = segue.destinationViewController;
        NSIndexPath* indexPath = sender;
        NSDictionary* chatRoom = self.dataSource[indexPath.row];
        cvc.conversationType = ConversationType_CHATROOM;
        cvc.targetId = chatRoom[@"chrmId"];
    }
}


@end
