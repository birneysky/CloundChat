//
//  ChatRoomCell.m
//  CloudChat
//
//  Created by birneysky on 2017/4/11.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCTableViewCell.h"

@implementation CCTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.contentView.bounds.size.height;
    
    CGFloat imageHeight = height - 2 * 4;
    
    CGRect imageFrame = self.imageView.frame;
    
    imageFrame.origin.y = 4;
    imageFrame.size = CGSizeMake(imageHeight, imageHeight);
    
    self.imageView.frame = imageFrame;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
