//
//  RCSightRecorder.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

static NSString *const VideoFilename = @"sight.mp4";

@interface CCSightRecorder ()

@property (strong, nonatomic) AVAssetWriter *assetWriter;                   // 1
@property (strong, nonatomic) AVAssetWriterInput *assetWriterVideoInput;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterAudioInput;
@property (strong, nonatomic)
AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelBufferAdaptor;

@property (strong, nonatomic) dispatch_queue_t dispatchQueue;


@property (strong, nonatomic) NSDictionary *videoSettings;
@property (strong, nonatomic) NSDictionary *audioSettings;

@property (nonatomic) BOOL isWriting;

@property (nonatomic) BOOL firstSample;

@end


@implementation CCSightRecorder

- (instancetype)initWithVideoSettings:(NSDictionary *)videoSettings
                        audioSettings:(NSDictionary *)audioSettings
                        dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    if (self = [super init]) {
        self.videoSettings = [videoSettings copy];
        self.audioSettings = [audioSettings copy];
        self.dispatchQueue = dispatchQueue;
        
        self.firstSample = YES;
    
    }
    return self;
}

#pragma mark - Properties
- (AVAssetWriter *)assetWriter
{
  if (!_assetWriter) {
    NSError* error = nil;
    _assetWriter = [[AVAssetWriter alloc] initWithURL:self.url fileType:AVFileTypeMPEG4 error:&error];
  }
  return _assetWriter;
}



#pragma mark - Api

- (void)prepareToRecord
{
    dispatch_async(self.dispatchQueue, ^{
        
        NSError *error = nil;
        
        NSString *fileType = AVFileTypeQuickTimeMovie;
        self.assetWriter = [AVAssetWriter assetWriterWithURL:[self outputURL]
                                                    fileType:fileType
                                                       error:&error];
        if (!self.assetWriter || error) {
            NSString *formatString = @"Could not create AVAssetWriter: %@";
            NSLog(@"%@", [NSString stringWithFormat:formatString, error]);
            return;
        }
        
        self.assetWriterVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo
                                                                    outputSettings:self.videoSettings];
        
        self.assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        self.assetWriterVideoInput.transform = transformForDeviceOrientation(orientation);
        
        NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (id)kCVPixelBufferWidthKey : self.videoSettings[AVVideoWidthKey],
                                     (id)kCVPixelBufferHeightKey : self.videoSettings[AVVideoHeightKey],
                                     (id)kCVPixelFormatOpenGLESCompatibility : (id)kCFBooleanTrue};
        
        self.assetWriterInputPixelBufferAdaptor =
            [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.assetWriterVideoInput
                                                       sourcePixelBufferAttributes:attributes];
        
        
        if ([self.assetWriter canAddInput:self.assetWriterVideoInput]) {
            [self.assetWriter addInput:self.assetWriterVideoInput];
        } else {
            NSLog(@"Unable to add video input.");
            return;
        }
        
        self.assetWriterAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                    outputSettings:self.audioSettings];
        
        self.assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:self.assetWriterAudioInput]) {
            [self.assetWriter addInput:self.assetWriterAudioInput];
        } else {
            NSLog(@"Unable to add audio input.");
        }
        
        self.isWriting = YES;
        self.firstSample = YES;
    });
}



- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!self.isWriting) {
        return;
    }
    
    CMFormatDescriptionRef formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMMediaType mediaType = CMFormatDescriptionGetMediaType(formatDesc);
    
    if (mediaType == kCMMediaType_Video) {
        
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if (self.firstSample) {
            if ([self.assetWriter startWriting]) {
                [self.assetWriter startSessionAtSourceTime:timestamp];
            } else {
                NSLog(@"Failed to start writing.");
            }
            self.firstSample = NO;
        }

        CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if (self.assetWriterVideoInput.readyForMoreMediaData) {
            if (![self.assetWriterInputPixelBufferAdaptor appendPixelBuffer:imageBuffer
                                                       withPresentationTime:timestamp]) {
                NSLog(@"Error appending pixel buffer.");
            }
        }
        
    }
    else if (!self.firstSample && mediaType == kCMMediaType_Audio) {
        if (self.assetWriterAudioInput.isReadyForMoreMediaData) {
            if (![self.assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                NSLog(@"Error appending audio sample buffer.");
            }
        }
    }

}



- (void)finishRecording
{
    
    self.isWriting = NO;
    dispatch_async(self.dispatchQueue, ^{

        [self.assetWriter finishWritingWithCompletionHandler:^{
            
            if (self.assetWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *fileURL = [self.assetWriter outputURL];
                    [self.delegate didWriteMovieAtURL:fileURL];
                });
            } else {
                NSLog(@"Failed to write movie: %@", self.assetWriter.error);
            }
        }];
    });

}


#pragma mark - helpers
- (NSURL *)outputURL {
    NSString *filePath =
    [NSTemporaryDirectory() stringByAppendingPathComponent:VideoFilename];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    return url;
}

CGAffineTransform transformForDeviceOrientation(UIDeviceOrientation orientation) {
    CGAffineTransform result;
    
    switch (orientation) {
            
        case UIDeviceOrientationLandscapeRight:
            result = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            result = CGAffineTransformMakeRotation((M_PI_2 * 3));
            break;
            
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            result = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default: /// landscape left
            result = CGAffineTransformIdentity;
            break;
    }
    
    return result;
}

@end
