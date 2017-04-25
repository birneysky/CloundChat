//
//  RCSightCapturer.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "RCSightCapturer1.h"


@interface RCSightCapturer1 () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,strong) AVCaptureDevice *videoDevice;

@property (nonatomic,strong) AVCaptureDevice *audioDevice;

@property (nonatomic,strong) dispatch_queue_t sessionQueue;

@property (nonatomic,strong) AVCaptureConnection *audioConnection;

@property (nonatomic,strong) AVCaptureConnection *videoConnection;

@end


@implementation RCSightCapturer1

- (instancetype) initWithVideoPreviewPlayer:(AVCaptureVideoPreviewLayer*)layer
{
  if (self = [super init]) {
    layer.session = self.captureSession;
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

- (AVCaptureDevice*)videoDevice
{
  if(!_videoDevice){
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  }
  return _videoDevice;
}

- (AVCaptureDevice*)audioDevice
{
  if (!_audioDevice) {
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
  }
  return _audioDevice;
}

#pragma mark - Helper
- (void)setupCaptureSession{
  if ( _captureSession ) {
    return;
  }
  
  /*audio*/
  AVCaptureDeviceInput *audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
  if ([self.captureSession canAddInput:audioDeviceInput]) {
    [self.captureSession addInput:audioDeviceInput];
  }
  
  AVCaptureAudioDataOutput *audioDeviceOutput = [[AVCaptureAudioDataOutput alloc] init];
  dispatch_queue_t audioCaptureQueue = dispatch_queue_create("com.rongcloud.sightcapturer.audio", DISPATCH_QUEUE_SERIAL );
  [audioDeviceOutput setSampleBufferDelegate:self queue:audioCaptureQueue];
  
  if ([self.captureSession canAddOutput:audioDeviceOutput]) {
    [self.captureSession addOutput:audioDeviceOutput];
  }
  
  /*video*/
  
  
  AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:nil];
  if ([self.captureSession canAddInput:videoDeviceInput]) {
    [self.captureSession addInput:videoDeviceInput];
  }
  
  AVCaptureVideoDataOutput *videoDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
  videoDeviceOutput.videoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32RGBA) };
  dispatch_queue_t videoDataOutputQueue = dispatch_queue_create( "com.rongcloud.sightcapturer.video", DISPATCH_QUEUE_SERIAL );
  [videoDeviceOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
  videoDeviceOutput.alwaysDiscardsLateVideoFrames = NO;
  
  
  if ([self.captureSession canAddOutput:videoDeviceOutput]) {
    [self.captureSession addOutput:videoDeviceOutput];
  }
  
  self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
  
  CMTime frameDuration = CMTimeMake( 1, 15 );
  
  NSError *error = nil;
  if ( [self.videoDevice lockForConfiguration:&error] ) {
    self.videoDevice.activeVideoMaxFrameDuration = frameDuration;
    self.videoDevice.activeVideoMinFrameDuration = frameDuration;
    [self.videoDevice unlockForConfiguration];
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

#pragma mark - Api
- (void)startRunning
{
  
}


- (void)stopRunning
{
  
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
