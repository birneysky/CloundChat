//
//  RCSightView.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CCSightViewDelegate <NSObject>

- (void)cancelVideoPreview;


@end


#define ActionBtnSize 104
#define BottomSpace 10
#define OKBtnSize 60
#define AnimateDuration 0.2

@interface CCSightView : UIView

@property (nonatomic,weak) id<CCSightViewDelegate> delegate;


@property (nonatomic,readonly) AVCaptureVideoPreviewLayer *previewLayer;


@end
