//
//  RCSightMessage.m
//  RongIMLib
//
//  Created by LiFei on 2016/12/1.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCSightMessage.h"
#import "RCLocalConfiguration.h"
#import "RCUtilities.h"
#import "RCDictionary.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>

@interface RCSightMessage ()
@property (nonatomic, strong) NSString *thumbnailBase64String;

@end

@implementation RCSightMessage

+ (instancetype)messageWithLocalPath:(NSURL *)path {
  RCSightMessage *sightMessage = [[RCSightMessage alloc] init];
  if (sightMessage) {
    sightMessage.localPath = [path absoluteString];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *image = nil;
    if (error) {
      RCLogE(@"ERROR: RCSightMessage get thumbnail error: %@", [error localizedDescription]);
    } else {
      image = [[UIImage alloc] initWithCGImage:imageRef];
    }
    CGImageRelease(imageRef);
    if (image) {
      sightMessage.thumbnailImage = [RCUtilities
                                     generateThumbnail:image
                                     targetSize:CGSizeMake([RCLocalConfiguration sharedInstance]
                                                           .thumbnailWidth,
                                                           [RCLocalConfiguration sharedInstance]
                                                           .thumbnailHeight)];
    }
  }
  return sightMessage;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED;
}

+ (NSString *)getObjectName {
  return RCSightMessageTypeIdentifier;
}

#pragma mark -NSCoding protocol methods
#define KEY_SIGHTMSG_LOCALPATH @"localPath"
#define KEY_SIGHTMSG_REMOTEURL @"remoteUrl"
#define KEY_SIGHTMSG_THUMBNAILIMAGE @"thumbnailImage"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.localPath = [aDecoder decodeObjectForKey:KEY_SIGHTMSG_LOCALPATH];
    self.remoteUrl = [aDecoder decodeObjectForKey:KEY_SIGHTMSG_REMOTEURL];
    self.thumbnailImage = [aDecoder decodeObjectForKey:KEY_SIGHTMSG_THUMBNAILIMAGE];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.localPath forKey:KEY_SIGHTMSG_LOCALPATH];
  [aCoder encodeObject:self.remoteUrl forKey:KEY_SIGHTMSG_REMOTEURL];
  [aCoder encodeObject:self.thumbnailImage forKey:KEY_SIGHTMSG_THUMBNAILIMAGE];
}

#pragma mark - RCMessageCoding delegate methods
- (NSData *)encode {
  NSData *imageData = UIImageJPEGRepresentation(self.thumbnailImage, [RCLocalConfiguration sharedInstance].thumbnailQuality);
  NSString *thumbnailBase64String = nil;
  if ([imageData
       respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
    thumbnailBase64String =
    [imageData base64EncodedStringWithOptions:kNilOptions];
  } else {
    thumbnailBase64String = [RCUtilities base64EncodedStringFrom:imageData];
  }
  RCLogV(@"thumbnailBase64String = %ld",
         (unsigned long)thumbnailBase64String.length);
  
  NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:thumbnailBase64String, @"content", nil];
  if (self.localPath.length > 0) {
    [dataDict setValue:self.localPath forKey:@"localPath"];
  }
  if (self.remoteUrl.length > 0) {
    [dataDict setValue:self.remoteUrl forKey:@"remoteUrl"];
  }
  if (self.senderUserInfo) {
    NSMutableDictionary *__dic = [[NSMutableDictionary alloc] init];
    if (self.senderUserInfo.name) {
      [__dic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
    }
    if (self.senderUserInfo.portraitUri) {
      [__dic setObject:self.senderUserInfo.portraitUri
     forKeyedSubscript:@"icon"];
    }
    if (self.senderUserInfo.userId) {
      [__dic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
    }
    [dataDict setObject:__dic forKey:@"user"];
  }
  if (self.mentionedInfo) {
    NSMutableDictionary *mentionedInfodic = [[NSMutableDictionary alloc] init];
    [mentionedInfodic setObject:@(self.mentionedInfo.type) forKeyedSubscript:@"type"];
    if (self.mentionedInfo.type == RC_Mentioned_Users) {
      [mentionedInfodic setObject:self.mentionedInfo.userIdList
                forKeyedSubscript:@"userIdList"];
    }
    [mentionedInfodic setObject:self.mentionedInfo.mentionedContent
              forKeyedSubscript:@"mentionedContent"];
    [dataDict setObject:mentionedInfodic forKey:@"mentionedInfo"];
  }
  
  NSError *__error = nil;
  // using serialize dict directly, apple doc says, this api produces UTF-8
  // encoded data
  NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                 options:kNilOptions
                                                   error:&__error];
  return data;

}

- (void)decodeWithData:(NSData *)data {
  NSError *__error = nil;
  if (!data) {
    return;
  }
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:&__error];
  RCDictionary *jsonDictionary = [[RCDictionary alloc] initWithDictionary:json];
  if (jsonDictionary) {
    self.localPath = [jsonDictionary stringObjectForKey:@"localPath"];
    self.remoteUrl = [jsonDictionary stringObjectForKey:@"remoteUrl"];
    self.thumbnailBase64String = [jsonDictionary stringObjectForKey:@"content"];
    NSDictionary *userinfoDic = [jsonDictionary objectForKey:@"user"];
    [super decodeUserInfo:userinfoDic];
    NSDictionary *mentionedInfoDic = [json objectForKey:@"mentionedInfo"];
    [self decodeMentionedInfo:mentionedInfoDic];
  } else {
    RCLogE(@"ERROR: RCSightMessage JSON is nil!!");
  }
}

- (UIImage *)thumbnailImage {
  if (!_thumbnailImage) {
    if (self.thumbnailBase64String) {
      NSData *imageData = nil;
      if (class_getInstanceMethod(
                                  [NSData class],
                                  @selector(initWithBase64EncodedString:options:))) {
        imageData = [[NSData alloc]
                     initWithBase64EncodedString:self.thumbnailBase64String
                     options:
                     NSDataBase64DecodingIgnoreUnknownCharacters];
      } else {
        imageData = [RCUtilities
                     dataWithBase64EncodedString:self.thumbnailBase64String];
      }
      _thumbnailImage = [UIImage imageWithData:imageData];
    } else {
      RCLogI(@">>>>>>>> Error!!!!!!!! thumbnail is missing...");
    }
  }
  return _thumbnailImage;
}

- (NSString *)localPath {
  if ([RCUtilities isLocalPath:_localPath]) {
    _localPath = [RCUtilities getCorrectedFilePath:_localPath];
  }
  return _localPath;
}

@end