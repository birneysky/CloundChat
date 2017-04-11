//
//  CCContactTableViewController.m
//  CloudChat
//
//  Created by birney on 2017/4/11.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCContactTableViewController.h"
#import "CCGroupAndUserDataSet.h"
#import "CCChatViewController.h"

@interface CCContactTableViewController ()

@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation CCContactTableViewController

#pragma mark - Properties
- (NSMutableArray*)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
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

    NSArray* array = @[@"群组"];
    [self.dataSource addObject:array];
    
    [self.dataSource addObject:[CCGroupAndUserDataSet defalutSet].allUserIds];
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
    NSArray* array = self.dataSource[section];
    return array.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (0 == indexPath.section) {
        cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    }
    else{
        NSString* userId = self.dataSource[indexPath.section][indexPath.row];
        RCUserInfo* userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
        cell.textLabel.text = userInfo.name;
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row && 0 == indexPath.section) {
        
    }
    else{
        [self performSegueWithIdentifier:@"segue_show_conversation_detail" sender:indexPath];
    }
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue_show_conversation_detail"]) {
        NSIndexPath* indexPath = sender;
        CCChatViewController* cvc =  segue.destinationViewController;
        NSString* userId = self.dataSource[indexPath.section][indexPath.row];
        RCUserInfo* userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
        cvc.conversationType = ConversationType_PRIVATE;
        cvc.targetId =  userInfo.userId;
    }
}


@end
