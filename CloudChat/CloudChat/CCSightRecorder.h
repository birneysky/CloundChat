//
//  RCSightRecorder.h
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>


@protocol CCSightRecorderDelegate;

/**
 视频录制器，负责视频文件的生成。
 */
@interface CCSightRecorder : NSObject

/**
 初始化recorder

 @param videoSettings 视频设置
 @param audioSettings 音频设置
 @param dispatchQueue 队列
 @return 返回recorder对象
 */
- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
              audioSettings:(NSDictionary *)audioSettings
              dispatchQueue:(dispatch_queue_t)dispatchQueue;


/**
 视频文件本地路径
 */
@property (nonatomic,readonly,strong) NSURL* url;


/**
 录制对象代理
 */
@property (nonatomic,readwrite,weak) id<CCSightRecorderDelegate> delegate;

/**
 准备录制
 
 @discussion  异步调用
 */
- (void)prepareToRecord;


/**
 向recorder中处理 媒体样本 （视频帧,音频样本）

 @param sampleBuffer 未编码的视频样本
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 结束录制
 
 @discussion 异步调用，完成时调用sightRecorderDidFinishRecording： 失败调用sightRecorder:didFailWithError:
 */
- (void)finishRecording;

@end


@protocol CCSightRecorderDelegate <NSObject>
@required
/**
 完成视频录制时会被调用
 
 @param outputURL 文件存储路径
 */
- (void)didWriteMovieAtURL:(NSURL *)outputURL;

@end
