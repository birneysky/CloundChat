//
//  RCSightView.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol RCSightViewDelegate <NSObject>

- (void)cancelVideoPreview;


@end


@interface RCSightView1 : UIView

@property (nonatomic,weak) id<RCSightViewDelegate> delegate;


@property (nonatomic,readonly) AVCaptureVideoPreviewLayer *previewLayer;


@end
