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

 @param URL 录制文件存储路径
 @param delegate recorder代理
 @return 返回recorder对象
 */
- (instancetype)initWithURL:(NSURL *)URL delegate:(id<CCSightRecorderDelegate>)delegate;


/**
 准备录制
 
 @discussion  异步调用，准备完成会调用sightRecorderDidFinishPreparing： 失败调用sightRecorder:didFailWithError:
 */
- (void)prepareToRecord;


/**
 向recorder中追加视频帧

 @param sampleBuffer 未编码视频帧对象
 */
- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;


/**
 向recorder中追加音频样本

 @param sampleBuffer 为编码音频样本
 */
- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;



/**
 结束录制
 
 @discussion 异步调用，完成时调用sightRecorderDidFinishRecording： 失败调用sightRecorder:didFailWithError:
 */
- (void)finishRecording;


- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings;

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings;


@end


@protocol CCSightRecorderDelegate <NSObject>
@required

/**
 录制视频准备工作完成时是会调用

 @param recorder 录制对象
 */
- (void)sightRecorderDidFinishPreparing:(CCSightRecorder *)recorder;

/**
 准备录制或者开始录制过程出现错误

 @param recorder 录制对象
 @param error 错误信息
 */
- (void)sightRecorder:(CCSightRecorder *)recorder didFailWithError:(NSError *)error;

/**
 完成视频录制时会被调用

 @param recorder 录制对象
 */
- (void)sightRecorderDidFinishRecording:(CCSightRecorder *)recorder;

@end
