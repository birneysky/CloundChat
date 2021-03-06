//
//  RCDCustomerEmoticonTab.h
//  CloudChat
//
//  Created by birneysky on 2017/3/29.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>


@protocol CCCustomerEmoticionTabDelegate <NSObject>

- (void)factButtonClickedAtIndex:(NSUInteger)index;

@end

@interface CCCustomerEmoticonTab : NSObject <RCEmoticonTabSource>

@property (nonatomic,weak) id<CCCustomerEmoticionTabDelegate> delegate;

@property(nonatomic,copy) NSString* identify;
@property(nonatomic,strong) UIImage* image;
@property(nonatomic,assign) int pageCount;

-(UIView *)loadEmoticonView:(NSString *)identify index:(int)index;

@end
