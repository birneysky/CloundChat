//
//  RCSightCapturer.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCSightCapturer1.h"


@interface RCSightCapturer1 () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,weak) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic,strong) AVCaptureDevice *audioDevice;

@property (nonatomic,strong) dispatch_queue_t sessionQueue;

@property (nonatomic,strong) AVCaptureConnection *audioConnection;

@property (nonatomic,strong) AVCaptureConnection *videoConnection;

@property (nonatomic,strong) AVCaptureStillImageOutput* imageOutput;

@end


@implementation RCSightCapturer1

- (instancetype) initWithVideoPreviewPlayer:(AVCaptureVideoPreviewLayer*)layer
{
  if (self = [super init]) {
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.session = self.captureSession;
    [self setupCaptureSession];
  }
  return self;
}


#pragma mark - Properties
- (AVCaptureSession*)captureSession
{
  if (!_captureSession) {
    _captureSession = [[AVCaptureSession alloc] init];
  }
  return _captureSession;
}


- (AVCaptureDevice*)audioDevice
{
  if (!_audioDevice) {
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
  }
  return _audioDevice;
}

- (dispatch_queue_t)sessionQueue
{
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create( "com.rongcloud.sightcapturer.session", DISPATCH_QUEUE_SERIAL );
    }
    return _sessionQueue;
}

- (AVCaptureStillImageOutput*)imageOutput
{
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        _imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    }
    return _imageOutput;
}

#pragma mark - Helper
- (void)setupCaptureSession{

  
  /*audio*/
  AVCaptureDeviceInput *audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
  if ([self.captureSession canAddInput:audioDeviceInput]) {
    [self.captureSession addInput:audioDeviceInput];
  }
  
  AVCaptureAudioDataOutput *audioDeviceOutput = [[AVCaptureAudioDataOutput alloc] init];
  dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.rongcloud.sightcapturer.audio.output", DISPATCH_QUEUE_SERIAL );
  [audioDeviceOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
  
  if ([self.captureSession canAddOutput:audioDeviceOutput]) {
    [self.captureSession addOutput:audioDeviceOutput];
  }
  
  /*video*/
  
  AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
  if ([self.captureSession canAddInput:videoDeviceInput]) {
    [self.captureSession addInput:videoDeviceInput];
      self.activeVideoInput = videoDeviceInput;
  }
  
  AVCaptureVideoDataOutput *videoDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
  ///videoDeviceOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32RGBA) };
  dispatch_queue_t videoDataOutputQueue = dispatch_queue_create( "com.rongcloud.sightcapturer.video.output", DISPATCH_QUEUE_SERIAL );
  [videoDeviceOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
  videoDeviceOutput.alwaysDiscardsLateVideoFrames = NO;
  
  
  if ([self.captureSession canAddOutput:videoDeviceOutput]) {
    [self.captureSession addOutput:videoDeviceOutput];
  }
  
    if([self.captureSession canAddOutput:self.imageOutput]){
        [self.captureSession addOutput:self.imageOutput];
    }
    
  self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
  
  CMTime frameDuration = CMTimeMake( 1, 15 );
  
  NSError *error = nil;
  if ( [videoDevice lockForConfiguration:&error] ) {
    videoDevice.activeVideoMaxFrameDuration = frameDuration;
    videoDevice.activeVideoMinFrameDuration = frameDuration;
    [videoDevice unlockForConfiguration];
  }

}

- (void)teardownCaptureSession
{
  if (self.captureSession )
  {
   /// [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self.captureSession];
    
    
    
    self.captureSession = nil;
    
    ///_videoCompressionSettings = nil;
    ///_audioCompressionSettings = nil;
  }
}

- (BOOL)canSwitchCameras
{
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice* device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice*)activeCamera{
    return self.activeVideoInput.device;
}

- (AVCaptureDevice*)inactiveCamera{
    AVCaptureDevice* device = nil;
    if (self.cameraCount > 1) {
        if (AVCaptureDevicePositionBack == [self activeCamera].position) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else{
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (BOOL)switchCamera{
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError* error;
    AVCaptureDevice* videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput* videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
        else{
            [self.captureSession addInput:self.activeVideoInput];
        }
        [self.captureSession commitConfiguration];
    }
    else{
        ////errror
        return NO;
    }
    return YES;
}

#pragma mark - Api
- (void)startRunning
{
    if (![self.captureSession isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.captureSession startRunning];
        });
    }
}


- (void)stopRunning
{
    if ([self.captureSession isRunning]) {
        dispatch_async(self.sessionQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}



- (void)startRecording
{
  
}


- (void)stopRecording
{
  
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
  
}
@end
