//
//  RCSightViewController.h
//  CloudChat
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCSightViewControllerDelegate <NSObject>

- (void)sightViewController:(UIViewController*)sightVC didFinishCapturingStillImage:(UIImage*)image;

- (void)sightViewController:(UIViewController *)sightVC didWriteSightAtURL:(NSURL *)url thumbnail:(UIImage*)thumnail;

@end

@interface CCSightViewController : UIViewController

@property (nonatomic,weak) id<CCSightViewControllerDelegate> delegate;

@end
