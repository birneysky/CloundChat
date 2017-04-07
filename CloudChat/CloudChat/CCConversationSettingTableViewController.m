//
//  CCConversationSettingTableViewController.m
//  CloudChat
//
//  Created by birney on 2017/4/7.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCConversationSettingTableViewController.h"

@interface CCConversationSettingTableViewController () <UIActionSheetDelegate>

@property (nonatomic,copy) NSArray* dataSource;

@end

@implementation CCConversationSettingTableViewController

#pragma mark - Properties
- (NSArray*)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@"消息免打扰",@"会话置顶",@"清除消息记录"];
    }
    return _dataSource;
}

#pragma mark - Init
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationSettingCell" forIndexPath:indexPath];
    
    NSString* settingTitle = self.dataSource[indexPath.row];
    if ([settingTitle isEqualToString:@"清除消息记录"]) {
        cell.accessoryView = nil;
        
    }
    else if(!cell.accessoryView){
        UISwitch* switchBtn = [[UISwitch alloc] init];
        [switchBtn addTarget:self action:@selector(cellSwitch:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
        
        if ([settingTitle isEqualToString:@"消息免打扰"]) {
            switchBtn.on = self.isDisturb;
        }
        else if([settingTitle isEqualToString:@"会话置顶"]){
            switchBtn.on = self.isTop;
        }
    }
    
    // Configure the cell...
    
    cell.accessoryView.tag = indexPath.row;
    
    cell.textLabel.text = settingTitle;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* settingTitle = self.dataSource[indexPath.row];
    if ([settingTitle isEqualToString:@"清除消息记录"]) {
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"清空聊天记录 ？"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil ];
        [sheet showInView:self.view];
    }
}


#pragma mark - Target Action
- (void)cellSwitch:(UISwitch*)sender
{
    //////RCConversation* conversation = [[RCIMClient sharedRCIMClient] getConversation:self.conversationType targetId:self.targetId];
    
    NSString* settingTitle =  self.dataSource[sender.tag];
    if ([settingTitle isEqualToString:@"消息免打扰"]) {
        [[RCIMClient sharedRCIMClient] setConversationNotificationStatus:self.conversationType targetId:self.targetId isBlocked:sender.isOn success:^(RCConversationNotificationStatus nStatus) {
            NSLog(@"设置免打扰消息状态成功");
        } error:^(RCErrorCode status) {
            
        }];
    }
    else if([settingTitle isEqualToString:@"会话置顶"]){
        [[RCIMClient sharedRCIMClient] setConversationToTop:self.conversationType targetId:self.targetId isTop:sender.isOn];
    }
}

#pragma mark - UIActionSheeteDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ///NSLog(@" button index %zi",buttonIndex);
    if(0 == buttonIndex){
        
    }
}








@end
