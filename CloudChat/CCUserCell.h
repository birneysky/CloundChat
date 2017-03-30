//
//  CCUserCell.h
//  CloudChat
//
//  Created by birney on 2017/3/30.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage.h>

@interface CCUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *avatarView;

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@end
