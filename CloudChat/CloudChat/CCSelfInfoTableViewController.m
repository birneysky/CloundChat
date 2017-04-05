//
//  CCSelfInfoTableViewController.m
//  CloudChat
//
//  Created by birney on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCSelfInfoTableViewController.h"
#import "CCSettingSelfInfoCell.h"
#import "RCDCustomerServiceViewController.h"

@interface CCSelfInfoTableViewController ()

@property (nonatomic,copy) NSArray* dataSource;

@end

@implementation CCSelfInfoTableViewController

#pragma mark - Properties

- (NSArray*)dataSource
{
    if (!_dataSource) {
        _dataSource = @[@"我",@"账号设置",@"意见反馈"];
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
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;//
    if (indexPath.section == 0) {
        CCSettingSelfInfoCell* selfInfoCell =  [tableView dequeueReusableCellWithIdentifier:@"SelfInfoCell" forIndexPath:indexPath];
        selfInfoCell.avatarImgView.yy_imageURL = [NSURL URLWithString:@"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1963497/way-back-home.gif"];
        selfInfoCell.nameLabel.text = @"haha";
        cell = selfInfoCell;
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"GeneralInfoCell" forIndexPath:indexPath];
        cell.textLabel.text = self.dataSource[indexPath.section];
        UIImage* imageIcon = nil;
        NSString* titileItem = self.dataSource[indexPath.section];
        if ([titileItem isEqualToString:@"账号设置"]) {
            imageIcon = [UIImage imageNamed:@"setting_up"];
            
        }
        else if([titileItem isEqualToString:@"意见反馈"]){
            imageIcon = [UIImage imageNamed:@"sevre_inactive"];
        }
        
        cell.imageView.image = imageIcon;
    }
    
    // Configure the cell...
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        return 66;
    }
    else{
        return 44.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* titileItem = self.dataSource[indexPath.section];
    if([titileItem isEqualToString:@"意见反馈"]){
        [self performSegueWithIdentifier:@"segue_show_customer_service" sender:indexPath];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"segue_show_customer_service"]) {
        RCDCustomerServiceViewController *chatService = (RCDCustomerServiceViewController*)segue.destinationViewController;
        chatService.conversationType = ConversationType_CUSTOMERSERVICE;
        chatService.targetId = @"KEFU149095592952669";
        chatService.title = @"客服";
    }
}


@end
