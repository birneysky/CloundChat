//
//  RCSightMessageCell.m
//  RongIMKit
//
//  Created by LiFei on 2016/12/5.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCSightMessageCell.h"
#import "RCKitUtility.h"
#import "RCKitCommonDefine.h"

extern const NSString *RCKitDispatchDownloadMediaNotification;

@interface RCSightMessageCell ()
@property(nonatomic, strong) UIImageView *maskView;
@property(nonatomic, strong) UIImageView *shadowMaskView;
@property(nonatomic, strong) UIView *shadowView;
@property(nonatomic, strong) UIView *playButtonView;
@end

@implementation RCSightMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
  CGFloat __messagecontentview_height = 0.0f;
  RCSightMessage *_sightMessage = (RCSightMessage *)model.content;
  
  CGSize imageSize = _sightMessage.thumbnailImage.size;
  //兼容240
  CGFloat imageWidth = 120;
  CGFloat imageHeight = 120;
  if (imageSize.width > 121 || imageSize.height > 121) {
    imageWidth = imageSize.width / 2.0f;
    imageHeight = imageSize.height / 2.0f;
  } else {
    imageWidth = imageSize.width;
    imageHeight = imageSize.height;
  }
  //图片half
  imageSize = CGSizeMake(imageWidth, imageHeight);
  __messagecontentview_height = imageSize.height;
  
  if (__messagecontentview_height < [RCIM sharedRCIM].globalMessagePortraitSize.height) {
    __messagecontentview_height = [RCIM sharedRCIM].globalMessagePortraitSize.height;
  }
  __messagecontentview_height += extraHeight;
  
  return CGSizeMake(collectionViewWidth, __messagecontentview_height);
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initialize];
  }
  
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self initialize];
  }
  return self;
}

- (void)initialize {
  self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectZero];
  self.thumbnailView.layer.masksToBounds = YES;
  [self.messageContentView addSubview:self.thumbnailView];
  
//  UILongPressGestureRecognizer *longPress =
//  [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
//  [self.pictureView addGestureRecognizer:longPress];
//  
  UITapGestureRecognizer *sightTap =
  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSight:)];
  [self.thumbnailView addGestureRecognizer:sightTap];
  self.thumbnailView.userInteractionEnabled = YES;
  
  //    UITapGestureRecognizer *progressViewTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPicture:)];
  //    progressViewTap.numberOfTapsRequired = 1;
  //    progressViewTap.numberOfTouchesRequired = 1;
  //    [self.progressView addGestureRecognizer:progressViewTap];
  //    self.progressView.userInteractionEnabled = YES;
  
  self.messageActivityIndicatorView = nil;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateDownloadMediaStatus:)
                                               name:RCKitDispatchDownloadMediaNotification
                                             object:nil];

}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDownloadMediaStatus:(NSNotification *)notify {
  NSDictionary *statusDic = notify.userInfo;
  if (self.model.messageId == [statusDic[@"messageId"] longValue]) {
    if ([statusDic[@"type"] isEqualToString:@"progress"]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.progressView isHidden]) {
          [self.progressView setHidden:NO];
          [self.progressView startAnimating];
        }
        [self.progressView updateProgress:[statusDic[@"progress"] intValue]];
      });
    } else if ([statusDic[@"type"] isEqualToString:@"success"]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView stopAnimating];
        [self.progressView setHidden:YES];
        RCSightMessage *sightContent = self.model.content;
        sightContent.localPath = statusDic[@"mediaPath"];
      });
    } else if ([statusDic[@"type"] isEqualToString:@"error"]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.progressView isHidden]) {
          [self.progressView stopAnimating];
          [self.progressView setHidden:YES];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:NSLocalizedStringFromTable(@"FileDownloadFailed",
                                                                 @"RongCloudKit", nil)
                              delegate:nil
                              cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"RongCloudKit",
                                                                           nil)
                              otherButtonTitles:nil];
        [alert show];
      });
    }
  }
}

- (void)setMaskImage:(UIImage *)maskImage shadowMaskView:(UIImage *)shadowMaskImage{
  if (_maskView == nil) {
    _maskView = [[UIImageView alloc] initWithImage:maskImage];
    
    _maskView.frame = self.thumbnailView.bounds;
    self.thumbnailView.layer.mask = _maskView.layer;
    self.thumbnailView.layer.masksToBounds = YES;
  } else {
    _maskView.image = maskImage;
    _maskView.frame = self.thumbnailView.bounds;
  }
  _shadowMaskView = [[UIImageView alloc] initWithImage:shadowMaskImage];
  
  _shadowMaskView.frame = CGRectMake(self.thumbnailView.frame.origin.x - 0.5, self.thumbnailView.frame.origin.y - 0.5, self.thumbnailView.frame.size.width + 1, self.thumbnailView.frame.size.height + 1);
  _shadowView.layer.masksToBounds=YES;
  _shadowView.layer.mask = _shadowMaskView.layer;
  [_shadowView removeFromSuperview];
  [self.messageContentView addSubview:_shadowView];
  [self.messageContentView bringSubviewToFront:self.thumbnailView];
  
}

- (void)setDataModel:(RCMessageModel *)model {
  [super setDataModel:model];
  self.thumbnailView.image = nil;
  self.shadowView = nil;
  self.shadowMaskView.image = nil;
  RCImageMessage *_imageMessage = (RCImageMessage *)model.content;
  if (_imageMessage) {
    //        self.pictureView.image = _imageMessage.thumbnailImage;
    
    CGSize imageSize = _imageMessage.thumbnailImage.size;
    //兼容240
    CGFloat imageWidth = 120;
    CGFloat imageHeight = 120;
    if (imageSize.width > 121 || imageSize.height > 121) {
      imageWidth = imageSize.width / 2.0f;
      imageHeight = imageSize.height / 2.0f;
    } else {
      imageWidth = imageSize.width;
      imageHeight = imageSize.height;
    }
    //图片half
    imageSize = CGSizeMake(imageWidth, imageHeight);
    CGRect messageContentViewRect = self.messageContentView.frame;
    self.thumbnailView.image =  _imageMessage.thumbnailImage;
    UIImage *maskImage = nil;
    UIImage *shadowMaskImage = nil;
    if (model.messageDirection == MessageDirection_RECEIVE) {
      messageContentViewRect.size.width = imageSize.width;
      messageContentViewRect.size.height = imageSize.height;
      self.messageContentView.frame = messageContentViewRect;
      maskImage = [RCKitUtility imageNamed:@"chat_from_bg_normal" ofBundle:@"RongCloud.bundle"];
      shadowMaskImage = [RCKitUtility imageNamed:@"chat_from_imagebg_normal" ofBundle:@"RongCloud.bundle"];
      self.thumbnailView.frame = CGRectMake(0.5, 0.5, imageSize.width-1, imageSize.height-1);
      maskImage = [maskImage
                   resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.8,
                                                                maskImage.size.height * 0.2, maskImage.size.width * 0.2)];
      
      shadowMaskImage = [shadowMaskImage
                         resizableImageWithCapInsets:UIEdgeInsetsMake(shadowMaskImage.size.height * 0.8, shadowMaskImage.size.width * 0.8,
                                                                      shadowMaskImage.size.height * 0.2, shadowMaskImage.size.width * 0.2)];
      _shadowView = [[UIView alloc]initWithFrame:CGRectMake(self.thumbnailView.frame.origin.x - 0.5, self.thumbnailView.frame.origin.y - 0.5, self.thumbnailView.frame.size.width + 1, self.thumbnailView.frame.size.height + 1)];
      _shadowView.backgroundColor= HEXCOLOR(0xc1c1c1);
      
    } else {
      messageContentViewRect.size.width = imageSize.width;
      messageContentViewRect.size.height = imageSize.height;
      messageContentViewRect.origin.x =
      self.baseContentView.bounds.size.width -
      (imageSize.width+ HeadAndContentSpacing + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
      self.messageContentView.frame = messageContentViewRect;
      self.thumbnailView.frame = CGRectMake(0.5, 0.5, imageSize.width-1, imageSize.height-1);
      maskImage = [RCKitUtility imageNamed:@"chat_to_bg_normal" ofBundle:@"RongCloud.bundle"];
      maskImage = [maskImage
                   resizableImageWithCapInsets:UIEdgeInsetsMake(maskImage.size.height * 0.8, maskImage.size.width * 0.2,
                                                                maskImage.size.height * 0.2, maskImage.size.width * 0.8)];
      shadowMaskImage = [RCKitUtility imageNamed:@"chat_to_imagebg_normal" ofBundle:@"RongCloud.bundle"];
      shadowMaskImage = [shadowMaskImage
                         resizableImageWithCapInsets:UIEdgeInsetsMake(shadowMaskImage.size.height * 0.8, shadowMaskImage.size.width * 0.2,
                                                                      shadowMaskImage.size.height * 0.2, shadowMaskImage.size.width * 0.8)];
      _shadowView = [[UIView alloc]initWithFrame:CGRectMake(self.thumbnailView.frame.origin.x - 0.5, self.thumbnailView.frame.origin.y - 0.5, self.thumbnailView.frame.size.width + 1, self.thumbnailView.frame.size.height + 1)];
      
      _shadowView.backgroundColor= HEXCOLOR(0x83cbfd);
    }
    [self setMaskImage:maskImage shadowMaskView:shadowMaskImage];
    self.progressView = [[RCImageMessageProgressView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.progressView setFrame:self.thumbnailView.bounds];
    [self.progressView setHidden:YES];
    [self.thumbnailView addSubview:self.progressView];
  } else {
    DebugLog(@"[RongIMKit]: RCMessageModel.content is NOT RCImageMessage object");
  }
  
  [self updateStatusContentView:self.model];
  if (model.sentStatus == SentStatus_SENDING) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.playButtonView setHidden:YES];
      
      [self.progressView startAnimating];
      [self.progressView setHidden:NO];
      self.thumbnailView.userInteractionEnabled = NO;
    });
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.playButtonView setHidden:NO];
      [self.progressView stopAnimating];
      [self.progressView setHidden:YES];
      self.thumbnailView.userInteractionEnabled = YES;
    });
  }
}

- (UIView *)playButtonView {
  if (!_playButtonView) {
    _playButtonView = [[UIView alloc] initWithFrame:self.thumbnailView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    label.text = @"播放";
    label.font = [UIFont systemFontOfSize:10];
    [label setCenter:CGPointMake(self.thumbnailView.bounds.size.width / 2, self.thumbnailView.bounds.size.height / 2)];
    [_playButtonView addSubview:label];
    [_playButtonView setBackgroundColor:[UIColor blackColor]];
    [_playButtonView setAlpha:0.7f];
    
    [self.thumbnailView addSubview:_playButtonView];
  }
  return _playButtonView;
}

- (void)messageCellUpdateSendingStatusEvent:(NSNotification *)notification {
  
  RCMessageCellNotificationModel *notifyModel = notification.object;
  
  NSInteger progress = notifyModel.progress;
  
  if (self.model.messageId == notifyModel.messageId) {
    DebugLog(@"messageCellUpdateSendingStatusEvent >%@ ", notifyModel.actionName);
    if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_BEGIN]) {
      self.model.sentStatus = SentStatus_SENDING;
      [self updateStatusContentView:self.model];
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView startAnimating];
        [self.progressView setHidden:NO];
        self.thumbnailView.userInteractionEnabled = NO;
      });
      
    } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_FAILED]) {
      self.model.sentStatus = SentStatus_FAILED;
      [self updateStatusContentView:self.model];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView stopAnimating];
        [self.progressView setHidden:YES];
        self.thumbnailView.userInteractionEnabled = YES;
      });
    } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_SUCCESS]) {
      if (self.model.sentStatus != SentStatus_READ) {
        self.model.sentStatus = SentStatus_SENT;
        [self updateStatusContentView:self.model];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.playButtonView setHidden:NO];
          [self.progressView stopAnimating];
          [self.progressView setHidden:YES];
          self.thumbnailView.userInteractionEnabled = YES;
        });
      }
    } else if ([notifyModel.actionName isEqualToString:CONVERSATION_CELL_STATUS_SEND_PROGRESS]) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView updateProgress:progress];
      });
    }
    else if (self.model.sentStatus == SentStatus_READ && self.isDisplayReadStatus) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView stopAnimating];
        [self.progressView setHidden:YES];
        self.thumbnailView.userInteractionEnabled = YES;
        self.messageHasReadStatusView.hidden = NO;
        self.messageFailedStatusView.hidden = YES;
        self.messageSendSuccessStatusView.hidden = YES;
        self.model.sentStatus = SentStatus_READ;
        [self updateStatusContentView:self.model];
        self.statusContentView.frame = CGRectMake(self.thumbnailView.frame.origin.x - 20 , self.thumbnailView.frame.size.height - 18 , 18, 18);
        
      });
      
    }
    
  }
}

- (void)tapSight:(UIGestureRecognizer *)gestureRecognizer {
  if ([self.delegate respondsToSelector:@selector(didTapMessageCell:)]) {
    [self.delegate didTapMessageCell:self.model];
  }
}

@end
