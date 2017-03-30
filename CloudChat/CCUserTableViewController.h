//
//  CCUserTableViewController.h
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CCUserTableViewController : UITableViewController

@property (nonatomic,copy) void (^selectBlock)(NSString* nickName, NSString* title,NSString* url);

@end
