//
//  RCSightCapturer.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightCapturer.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCSightRecorder.h"


typedef NS_ENUM( NSInteger, SightCapturerRecordingStatus )
{
  SightCapturerRecordingStatusIdle = 0,
  SightCapturerRecordingStatusStartingRecording,
  SightCapturerRecordingStatusRecording,
  SightCapturerRecordingStatusStoppingRecording,
}; // internal state machine


@interface CCSightCapturer () <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate,CCSightRecorderDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;

@property (nonatomic,weak) AVCaptureDeviceInput *activeVideoInput;

@property (nonatomic,strong) AVCaptureDevice *audioDevice;

@property (nonatomic,strong) AVCaptureDevice *videoDevice;

@property (nonatomic,strong) dispatch_queue_t sessionQueue;

@property (nonatomic,strong) AVCaptureConnection *audioConnection;

@property (nonatomic,strong) AVCaptureConnection *videoConnection;

@property (nonatomic,strong) AVCaptureStillImageOutput* imageOutput;

@property (nonatomic,assign) AVCaptureVideoOrientation videoBufferOrientation;

@property (nonatomic,copy) NSDictionary *videoCompressionSettings;
@property (nonatomic,copy) NSDictionary *audioCompressionSettings;

@property(nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property(nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property(nonatomic, assign)	SightCapturerRecordingStatus recordingStatus;

@property(nonatomic,strong) NSURL *recordUrl;

@property(nonatomic,strong) CCSightRecorder *recorder;

@end


@implementation CCSightCapturer

- (instancetype) initWithVideoPreviewPlayer:(AVCaptureVideoPreviewLayer*)layer
{
  if (self = [super init]) {
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.session = self.captureSession;
    [self setupCaptureSession];
  }
  return self;
}

- (void)dealloc{
  
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

- (AVCaptureDevice*)videoDevice
{
  if (!_videoDevice) {
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  }
  return _videoDevice;
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

- (NSURL*)recordUrl
{
  if (!_recordUrl) {
    _recordUrl = [[NSURL alloc] initFileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"Movie.mp4"]]];
  }
  return _recordUrl;
}

- (CCSightRecorder*)recorder
{
  if (!_recorder) {
    _recorder = [[CCSightRecorder alloc] initWithURL:self.recordUrl delegate:self];
  }
  return _recorder;
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
  self.audioConnection = [audioDeviceOutput connectionWithMediaType:AVMediaTypeAudio];
  
  
  
  /*video*/
  AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoDevice error:nil];
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
  
  self.videoConnection = [videoDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
  
  if([self.captureSession canAddOutput:self.imageOutput]){
    [self.captureSession addOutput:self.imageOutput];
  }
  
  self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
  
  CMTime frameDuration = CMTimeMake( 1, 15 );
  
  NSError *error = nil;
  if ( [self.videoDevice lockForConfiguration:&error] ) {
    self.videoDevice.activeVideoMaxFrameDuration = frameDuration;
    self.videoDevice.activeVideoMinFrameDuration = frameDuration;
    [self.videoDevice unlockForConfiguration];
  }
  
  self.audioCompressionSettings = [[audioDeviceOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4] copy];

  self.videoCompressionSettings = [[videoDeviceOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4] copy];
  
  self.videoBufferOrientation = self.videoConnection.videoOrientation;
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


- (AVCaptureVideoOrientation)currentVideoOrientation {
  
  AVCaptureVideoOrientation orientation;
  
  switch ([UIDevice currentDevice].orientation) {
    case UIDeviceOrientationPortrait:
      orientation = AVCaptureVideoOrientationPortrait;
      break;
    case UIDeviceOrientationLandscapeRight:
      orientation = AVCaptureVideoOrientationLandscapeLeft;
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      orientation = AVCaptureVideoOrientationPortraitUpsideDown;
      break;
    default:
      orientation = AVCaptureVideoOrientationLandscapeRight;
      break;
  }
  
  return orientation;
}


- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)orientation withAutoMirroring:(BOOL)mirror
{
  CGAffineTransform transform = CGAffineTransformIdentity;
		
  // Calculate offsets from an arbitrary reference orientation (portrait)
  CGFloat orientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( orientation );
  CGFloat videoOrientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( self.videoBufferOrientation );
  
  // Find the difference in angle between the desired orientation and the video orientation
  CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
  transform = CGAffineTransformMakeRotation( angleOffset );
  
  if ( _videoDevice.position == AVCaptureDevicePositionFront )
  {
    if ( mirror ) {
      transform = CGAffineTransformScale( transform, -1, 1 );
    }
    else {
      if ( UIInterfaceOrientationIsPortrait( (UIInterfaceOrientation)orientation ) ) {
        transform = CGAffineTransformRotate( transform, M_PI );
      }
    }
  }
  
  return transform;
}

static CGFloat angleOffsetFromPortraitOrientationToOrientation(AVCaptureVideoOrientation orientation)
{
  CGFloat angle = 0.0;
  
  switch ( orientation )
  {
    case AVCaptureVideoOrientationPortrait:
      angle = 0.0;
      break;
    case AVCaptureVideoOrientationPortraitUpsideDown:
      angle = M_PI;
      break;
    case AVCaptureVideoOrientationLandscapeRight:
      angle = -M_PI_2;
      break;
    case AVCaptureVideoOrientationLandscapeLeft:
      angle = M_PI_2;
      break;
    default:
      break;
  }
  
  return angle;
}

#pragma mark - Api
- (void)startRunning
{
  if (![self.captureSession isRunning]) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
      [weakSelf.captureSession startRunning];
    });
  }
}


- (void)stopRunning
{
  if ([self.captureSession isRunning]) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.sessionQueue, ^{
      [weakSelf.captureSession stopRunning];
    });
  }
}



- (void)startRecording
{
  @synchronized( self )
  {
    if ( self.recordingStatus != SightCapturerRecordingStatusIdle ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
      return;
    }
  }
  
  [self.recorder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:self.audioCompressionSettings];
  
  CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:AVCaptureVideoOrientationPortrait withAutoMirroring:NO]; // Front camera recording
  
  [self.recorder addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription transform:videoTransform settings:self.videoCompressionSettings];

  [self.recorder prepareToRecord];
}


- (void)stopRecording
{
  @synchronized( self )
  {
    if ( self.recordingStatus != SightCapturerRecordingStatusRecording ) {
      return;
    }
    
    
  }
  
  [_recorder finishRecording]; 
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

- (void)captureStillImage
{
  AVCaptureConnection *connection =
  [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
  
  if (connection.isVideoOrientationSupported) {
    connection.videoOrientation = [self currentVideoOrientation];
  }
  
  id handler = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
    if (sampleBuffer != NULL) {
      
      NSData *imageData =
      [AVCaptureStillImageOutput
       jpegStillImageNSDataRepresentation:sampleBuffer];
      
      UIImage *image = [[UIImage alloc] initWithData:imageData];
      
      if (self.captureStillImageCompletionHandler) {
        self.captureStillImageCompletionHandler(image);
      }
      ///[self writeImageToAssetsLibrary:image];                         // 1
      
    } else {
      NSLog(@"NULL sampleBuffer: %@", [error localizedDescription]);
    }
  };
  // Capture still image
  [self.imageOutput captureStillImageAsynchronouslyFromConnection:connection
                                                completionHandler:handler];
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
  
  if (connection == self.videoConnection) {
    if (!self.outputVideoFormatDescription) {
      CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription( sampleBuffer );
      self.outputVideoFormatDescription =  formatDescription;
    }
    
  }
  else if(connection == self.audioConnection){
    if (!self.outputAudioFormatDescription) {
      CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription( sampleBuffer );
      self.outputAudioFormatDescription = formatDescription;
    }
    
  }
  else{
    
  }
}

#pragma mark - CCSightRecorderDelegate

- (void)sightRecorderDidFinishPreparing:(CCSightRecorder *)recorder;
{
  
}

- (void)sightRecorder:(CCSightRecorder *)recorder didFailWithError:(NSError *)error;
{
  
}
- (void)sightRecorderDidFinishRecording:(CCSightRecorder *)recorder;
{
  @synchronized( self )
  {
    if ( _recordingStatus != SightCapturerRecordingStatusStoppingRecording ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
      return;
    }
    
    // No state transition, we are still in the process of stopping.
    // We will be stopped once we save to the assets library.
  }
  
  _recorder = nil;
  
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  [library writeVideoAtPathToSavedPhotosAlbum:self.recordUrl completionBlock:^(NSURL *assetURL, NSError *error) {
    
    [[NSFileManager defaultManager] removeItemAtURL:self.recordUrl error:NULL];
    
    @synchronized( self )
    {
      if ( self.recordingStatus != SightCapturerRecordingStatusStoppingRecording ) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
        return;
      }
      //[self transitionToRecordingStatus:RosyWriterRecordingStatusIdle error:error];
    }
  }];
}

@end
