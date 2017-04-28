//
//  RCSightRecorder.m
//  RongExtensionKit
//
//  Created by zhaobingdong on 2017/4/24.
//  Copyright © 2017年 RongCloud. All rights reserved.
//

#import "CCSightRecorder.h"
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM( NSInteger, SightRecorderStatus ) {
  SightRecorderStatusIdle = 0,
  SightRecorderStatusPreparingToRecord,
  SightRecorderStatusRecording,
  SightRecorderStatusFinishingRecordingPart1,
  SightRecorderStatusFinishingRecordingPart2,
  SightRecorderStatusFinished,
  SightRecorderStatusFailed
};


@interface CCSightRecorder ()

@property (nonatomic,strong) dispatch_queue_t writingQueue;

@property (nonatomic,assign) CGAffineTransform videoTrackTransform;

@property (nonatomic,strong) NSURL* url;

@property (nonatomic,weak) id<CCSightRecorderDelegate> delegate;

@property (nonatomic,strong) dispatch_queue_t delegateCallbackQueue;

@property (nonatomic,strong) AVAssetWriter *assetWriter;


@property (nonatomic,assign) SightRecorderStatus status;

@property (nonatomic,assign) BOOL haveStartedSession;

@end


@implementation CCSightRecorder
{
  
  AVAssetWriterInput *_videoInput;
  CMFormatDescriptionRef _videoTrackSourceFormatDescription;
  CGAffineTransform _videoTrackTransform;
  NSDictionary *_videoTrackSettings;

  
  AVAssetWriterInput *_audioInput;
  NSDictionary *_audioTrackSettings;
  CMFormatDescriptionRef _audioTrackSourceFormatDescription;
}

#pragma mark - init
- (instancetype)initWithURL:(NSURL *)URL delegate:(id<CCSightRecorderDelegate>)delegate
{
  NSParameterAssert( delegate != nil );
  NSParameterAssert( URL != nil );
  
  if (self = [super init]) {
    self.videoTrackTransform = CGAffineTransformIdentity;
    self.url = URL;
    self.delegate = delegate;
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

- (dispatch_queue_t)delegateCallbackQueue{
    if (!_delegateCallbackQueue) {
        _delegateCallbackQueue = dispatch_queue_create("com.rongcloud.sightrecorder.callback",DISPATCH_QUEUE_SERIAL);
    }
    return _delegateCallbackQueue;
}

- (dispatch_queue_t)writingQueue
{
    if (!_writingQueue) {
        _writingQueue  = dispatch_queue_create( "com.rongcloud.sightrecorder.writing", DISPATCH_QUEUE_SERIAL );
    }
    return _writingQueue;
}

#pragma mark - Api

- (void)prepareToRecord
{
//  @synchronized( self )
//  {
    if ( self.status != SightRecorderStatusIdle ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
      return;
    }
    
    [self transitionToStatus:SightRecorderStatusPreparingToRecord error:nil];
//  }
  
  dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 ), ^{
    
    @autoreleasepool
    {
      NSError *error = nil;
      // AVAssetWriter will not write over an existing file.
      [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
      
      
      
      // Create and add inputs
      if ( !error && _videoTrackSourceFormatDescription ) {
        [self setupAssetWriterVideoInputWithSourceFormatDescription:_videoTrackSourceFormatDescription transform:_videoTrackTransform settings:_videoTrackSettings error:&error];
      }
      
      if ( ! error && _audioTrackSourceFormatDescription ) {
        [self setupAssetWriterAudioInputWithSourceFormatDescription:_audioTrackSourceFormatDescription settings:_audioTrackSettings error:&error];
      }
      
      if ( ! error ) {
        BOOL success = [_assetWriter startWriting];
        if ( ! success ) {
          error = _assetWriter.error;
        }
      }
      
//      @synchronized( self )
//      {
        if ( error ) {
          [self transitionToStatus:SightRecorderStatusFailed error:error];
        }
        else {
          [self transitionToStatus:SightRecorderStatusRecording error:nil];
        }
//      }
    }
  } );
}

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings
{
  if ( formatDescription == NULL ) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
    return;
  }
  
//  @synchronized( self )
//  {
    if ( self.status != SightRecorderStatusIdle ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
      return;
    }
    
    if ( _audioTrackSourceFormatDescription ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one audio track" userInfo:nil];
      return;
    }
    
    _audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
    _audioTrackSettings = [audioSettings copy];
//  }
}

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings
{
  if ( formatDescription == NULL ) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
    return;
  }
  
//  @synchronized( self )
//  {
    if ( self.status != SightRecorderStatusIdle ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
      return;
    }
    
    if ( _videoTrackSourceFormatDescription ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one video track" userInfo:nil];
      return;
    }
    
    _videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
    _videoTrackTransform = transform;
    _videoTrackSettings = [videoSettings copy];
//  }
}



- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}



- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}


- (void)finishRecording
{
//  @synchronized( self )
//  {
    BOOL shouldFinishRecording = NO;
    switch ( self.status )
    {
      case SightRecorderStatusIdle:
      case SightRecorderStatusPreparingToRecord:
      case SightRecorderStatusFinishingRecordingPart1:
      case SightRecorderStatusFinishingRecordingPart2:
      case SightRecorderStatusFinished:
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not recording" userInfo:nil];
        break;
      case SightRecorderStatusFailed:
        // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
        // Because of this we are lenient when finishRecording is called and we are in an error state.
        NSLog( @"Recording has failed, nothing to do" );
        break;
      case SightRecorderStatusRecording:
        shouldFinishRecording = YES;
        break;
    }
    
    if ( shouldFinishRecording ) {
      [self transitionToStatus:SightRecorderStatusFinishingRecordingPart1 error:nil];
    }
    else {
      return;
    }
//  }
  
  dispatch_async( self.writingQueue, ^{
    
    @autoreleasepool
    {
      @synchronized( self )
      {
        // We may have transitioned to an error state as we appended inflight buffers. In that case there is nothing to do now.
        if ( _status != SightRecorderStatusFinishingRecordingPart1 ) {
          return;
        }
        
        // It is not safe to call -[AVAssetWriter finishWriting*] concurrently with -[AVAssetWriterInput appendSampleBuffer:]
        // We transition to MovieRecorderStatusFinishingRecordingPart2 while on _writingQueue, which guarantees that no more buffers will be appended.
        [self transitionToStatus:SightRecorderStatusFinishingRecordingPart2 error:nil];
      }
      
      [_assetWriter finishWritingWithCompletionHandler:^{
        @synchronized( self )
        {
          NSError *error = _assetWriter.error;
          if ( error ) {
            [self transitionToStatus:SightRecorderStatusFailed error:error];
          }
          else {
            [self transitionToStatus:SightRecorderStatusFinished error:nil];
          }
        }
      }];
    }
  } );
}


#pragma mark - helper

- (void)transitionToStatus:(SightRecorderStatus)newStatus error:(NSError *)error
{
  BOOL shouldNotifyDelegate = NO;
  
  NSLog( @"SightRecorder state transition: %@->%@", [self stringForStatus:_status], [self stringForStatus:newStatus] );
  
  if ( newStatus != self.status )
  {
    
    if ( ( newStatus == SightRecorderStatusFinished ) || ( newStatus == SightRecorderStatusFailed ) )
    {
      shouldNotifyDelegate = YES;
      // make sure there are no more sample buffers in flight before we tear down the asset writer and inputs
      
      dispatch_async( self.writingQueue, ^{
        [self teardownAssetWriterAndInputs];
        if ( newStatus == SightRecorderStatusFailed ) {
          [[NSFileManager defaultManager] removeItemAtURL:self.url error:NULL];
        }
      } );
      
      if ( error ) {
        NSLog( @"MovieRecorder error: %@, code: %i", error, (int)error.code );
      }
    }
    else if ( newStatus == SightRecorderStatusRecording )
    {
      shouldNotifyDelegate = YES;
    }
    
    _status = newStatus;
  }
  
  if ( shouldNotifyDelegate )
  {
    dispatch_async(self.delegateCallbackQueue, ^{
      @autoreleasepool
      {
        switch ( newStatus )
        {
          case SightRecorderStatusRecording:
            [self.delegate sightRecorderDidFinishPreparing:self];
            break;
          case SightRecorderStatusFinished:
            [self.delegate sightRecorderDidFinishRecording:self];
            break;
          case SightRecorderStatusFailed:
            [self.delegate sightRecorder:self didFailWithError:error];
            break;
          default:
            NSAssert1( NO, @"Unexpected recording status (%i) for delegate callback", (int)newStatus );
            break;
        }
      }
    } );
  }

}

- (NSString *)stringForStatus:(SightRecorderStatus)status
{
  NSString *statusString = nil;
  
  switch ( status )
  {
    case SightRecorderStatusIdle:
      statusString = @"Idle";
      break;
    case SightRecorderStatusPreparingToRecord:
      statusString = @"PreparingToRecord";
      break;
    case SightRecorderStatusRecording:
      statusString = @"Recording";
      break;
    case SightRecorderStatusFinishingRecordingPart1:
      statusString = @"FinishingRecordingPart1";
      break;
    case SightRecorderStatusFinishingRecordingPart2:
      statusString = @"FinishingRecordingPart2";
      break;
    case SightRecorderStatusFinished:
      statusString = @"Finished";
      break;
    case SightRecorderStatusFailed:
      statusString = @"Failed";
      break;
    default:
      statusString = @"Unknown";
      break;
  }
  return statusString;
  
}

- (void)teardownAssetWriterAndInputs
{
  _videoInput = nil;
  _audioInput = nil;
  self.assetWriter = nil;
}


- (BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut
{
  if ( ! videoSettings )
  {
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions( videoFormatDescription );
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    
    NSLog( @"No video settings provided, using default settings" );
    
    // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
    if ( numPixels < ( 640 * 480 ) ) {
      bitsPerPixel = 4.05; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
    }
    else {
      bitsPerPixel = 10.1; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30) };
    
    videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                       AVVideoWidthKey : @(dimensions.width),
                       AVVideoHeightKey : @(dimensions.height),
                       AVVideoCompressionPropertiesKey : compressionProperties };
  }
  
  if ( [self.assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo] )
  {
    _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
    _videoInput.expectsMediaDataInRealTime = YES;
    _videoInput.transform = transform;
    
    if ( [self.assetWriter canAddInput:_videoInput] )
    {
      [self.assetWriter addInput:_videoInput];
    }
    else
    {
      if ( errorOut ) {
        *errorOut = [[self class] cannotSetupInputError];
      }
      return NO;
    }
  }
  else
  {
    if ( errorOut ) {
      *errorOut = [[self class] cannotSetupInputError];
    }
    return NO;
  }
  
  return YES;
}


- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut
{
  if ( ! audioSettings ) {
    NSLog( @"No audio settings provided, using default settings" );
    audioSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC) };
  }
  
  if ( [self.assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio] )
  {
    _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
    _audioInput.expectsMediaDataInRealTime = YES;
    
    if ( [self.assetWriter canAddInput:_audioInput] )
    {
      [self.assetWriter addInput:_audioInput];
    }
    else
    {
      if ( errorOut ) {
        *errorOut = [[self class] cannotSetupInputError];
      }
      return NO;
    }
  }
  else
  {
    if ( errorOut ) {
      *errorOut = [[self class] cannotSetupInputError];
    }
    return NO;
  }
  
  return YES;
}

+ (NSError *)cannotSetupInputError
{
  NSString *localizedDescription = @"Recording cannot be started.";
  NSString *localizedFailureReason =  @"Cannot setup asset writer input.";
  NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : localizedDescription,
                               NSLocalizedFailureReasonErrorKey : localizedFailureReason };
  return [NSError errorWithDomain:@"com.apple.dts.samplecode" code:0 userInfo:errorDict];
}


- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
  if ( sampleBuffer == NULL ) {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
    return;
  }
  
//  @synchronized( self ) {
    if ( self.status < SightRecorderStatusRecording ) {
      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
      return;
    }
//  }
  
  CFRetain( sampleBuffer );
  dispatch_async( self.writingQueue, ^{
    
    @autoreleasepool
    {
      @synchronized( self )
      {
        // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
        // Because of this we are lenient when samples are appended and we are no longer recording.
        // Instead of throwing an exception we just release the sample buffers and return.
        if ( self.status > SightRecorderStatusFinishingRecordingPart1 ) {
          CFRelease( sampleBuffer );
          return;
        }
      }
      
      if ( ! _haveStartedSession ) {
        [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        _haveStartedSession = YES;
      }
      
      AVAssetWriterInput *input = ( mediaType == AVMediaTypeVideo ) ? _videoInput : _audioInput;
      
      if ( input.readyForMoreMediaData )
      {
        BOOL success = [input appendSampleBuffer:sampleBuffer];
        if ( ! success ) {
          NSError *error = _assetWriter.error;
          @synchronized( self ) {
            [self transitionToStatus:SightRecorderStatusFailed error:error];
          }
        }
      }
      else
      {
        NSLog( @"%@ input not ready for more media data, dropping buffer", mediaType );
      }
      CFRelease( sampleBuffer );
    }
  } );
}


@end
