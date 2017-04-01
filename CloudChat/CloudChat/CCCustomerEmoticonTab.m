//
//  RCDCustomerEmoticonTab.m
//  CloudChat
//
//  Created by birneysky on 2017/3/29.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCCustomerEmoticonTab.h"

@implementation CCCustomerEmoticonTab


-(UIView *)loadEmoticonView:(NSString *)identify index:(int)index;
{
    UIView *view = [[UIView alloc]
                    
                    initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 186)];
    
    view.backgroundColor = [UIColor blackColor];
    
    switch (index) {
            
        case 1:
            
            view.backgroundColor = [UIColor yellowColor];
            
            break;
            
        case 2:
            
            view.backgroundColor = [UIColor redColor];
            
            break;
            
        case 3:
            
            view.backgroundColor = [UIColor greenColor];
            
            break;
            
        case 4:
            
            view.backgroundColor = [UIColor grayColor];
            
            break;
            
            
            
        default:
            
            break;
            
    }
    
    return view;
}


@end
