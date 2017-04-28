//
//  CCSightOverlayView.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/28.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCSightTransport.h"


@interface CCSightOverlayView : UIView <CCSightTransport>

@property (weak, nonatomic) id <SightTransportDelegate> delegate;

@end
