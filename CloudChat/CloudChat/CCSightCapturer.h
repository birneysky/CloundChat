//
//  RCSightCapturer.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol CCSightCapturerDelegate <NSObject>

@required
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

/**
 视频，音频，图像采集者
 */
@interface CCSightCapturer : NSObject

- (instancetype) initWithVideoPreviewPlayer:(AVCaptureVideoPreviewLayer*)layer;

/**
 采集预览图层
 */
@property (nonatomic,readonly) AVCaptureVideoPreviewLayer* previewLayer;


/**
 视频帧和音频样本输出代理 一般会把这些数据交给SightRecorder
 */
@property (nonatomic,weak) id<CCSightCapturerDelegate> delegate;


/**
 拍摄图片回调block
 */
@property (nonatomic,copy) void (^captureStillImageCompletionHandler) (UIImage* image);

@property (nonatomic,strong,readonly) dispatch_queue_t sessionQueue;

@property (nonatomic,copy,readonly) NSDictionary *recommendedVideoCompressionSettings;
@property (nonatomic,copy,readonly) NSDictionary *recommendedAudioCompressionSettings;

/**
 开始采集
 */
- (void)startRunning;


/**
 结束采集
 */
- (void)stopRunning;


/**
 切换摄像头
 
 @return 成功返回YES，失败返回NO
 */
- (BOOL)switchCamera;


/**
 拍摄静止图片
 */
- (void)captureStillImage;

@end
