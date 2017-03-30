//
//  CCUserTableViewController.m
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCUserTableViewController.h"
#import "CCUserCell.h"

@interface CCUserTableViewController ()

@property (nonatomic,readonly) NSArray<NSString*>* names;
@property (nonatomic,readonly) NSArray<NSString*>* urls;
@property (nonatomic,readonly) NSArray<NSString*>* titles;

@end

@implementation CCUserTableViewController
{
    NSArray<NSString*>* _names;
    NSArray<NSString*>* _urls;
    NSArray<NSString*>* _titles;
}

#pragma mark - Properties
- (NSArray<NSString*>*)names
{
    if (!_names) {
        _names = @[@"Steve Jobs",@"a",@"b",@"c",@"d",@"e",@"c"];
    }
    return _names;
}

- (NSArray<NSString*>*)urls{
    if (!_urls) {
        _urls = @[@"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg",
                  @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2016158/avalanche.jpg",
                  @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1839353/pilsner.jpg",
                  @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1833469/porter.jpg",
                  @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/2025999/batman-beyond-the-rain.gif",
                  @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1855350/r_nin.gif",
                  @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1963497/way-back-home.gif",
                  @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1913272/depressed-slurp-cycle.gif"];
    }
    return _urls;
}

- (NSArray<NSString*>*)titles
{
    if (!_titles) {
        _titles = @[@"CEO",@"Developer",@"Developer",@"Developer",@"Developer",@"Developer",@"PM"];
    }
    return _titles;
}


#pragma mark - *** init ***
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to pres erve selection between presentations.
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
    return self.names.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
    
    
    cell.avatarView.yy_imageURL = [NSURL URLWithString: self.urls[indexPath.row]];
    cell.nickNameLabel.text = self.names[indexPath.row];
    cell.titleLabel.text = self.titles[indexPath.row];
    // Configure the cell...
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock) {
        self.selectBlock(self.names[indexPath.row], self.titles[indexPath.row], self.urls[indexPath.row]);
    }
    [self cancelBtnClicked:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Target Action

- (IBAction)cancelBtnClicked:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        NSIndexPath* indexPath =  [self.tableView indexPathForSelectedRow];
        if (indexPath) {
            
        }
    }];
}


@end
