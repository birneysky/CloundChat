//
//  CCSettingSelfInfoCell.h
//  CloudChat
//
//  Created by birney on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>


@interface CCSettingSelfInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
