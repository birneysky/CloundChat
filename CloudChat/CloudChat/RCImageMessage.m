/**
 * Copyright (c) 2014-2015, RongCloud.
 * All rights reserved.
 *
 * All the contents are the copyright of RongCloud Network Technology Co.Ltd.
 * Unless otherwise credited. http://rongcloud.cn
 *
 */

//  RCImageMessage.m
//  Created by Heq.Shinoda on 14-6-13.

#import "RCImageMessage.h"
#import "RCCommonDefine.h"
#import "RCDictionary.h"
#import "RCLocalConfiguration.h"
#import "RCUtilities.h"
#import <objc/runtime.h>

#define IMG_COMPRESSED_MAX_SIZE CGSizeMake(960, 960)
#define IMG_COMPRESSED_MAX_DATALEN 2000

extern UIImage *generateThumbnailImage(UIImage *oringialImage);

UIImage *generateThumbnailImage(UIImage *oringialImage) {
  UIImage *thumbnailImage = [RCUtilities
      generateThumbnail:oringialImage
                     targetSize:CGSizeMake([RCLocalConfiguration sharedInstance]
                                               .thumbnailWidth,
                                           [RCLocalConfiguration sharedInstance]
                                               .thumbnailHeight)];

  return thumbnailImage;
}

@interface RCImageMessage ()
@property(nonatomic, strong) NSString *thumbnailBase64String;
@end

@implementation RCImageMessage

+ (instancetype)messageWithImage:(UIImage *)image {
  RCImageMessage *message = [[RCImageMessage alloc] init];
  if (message) {
    message.thumbnailImage = generateThumbnailImage(image);
    message.originalImage = image;
  }
  return message;
}
+ (instancetype)messageWithImageURI:(NSString *)imageURI {
  RCImageMessage *message = [[RCImageMessage alloc] init];
  if (message) {
    message.imageUrl = imageURI ? imageURI : @"";
    message.originalImage = [UIImage imageWithContentsOfFile:imageURI];
    message.thumbnailImage = generateThumbnailImage(message.originalImage);
  }
  return message;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED;
}

#pragma mark - NSCoding protocol methods
#define KEY_IMAGEMSG_EXTRA @"extra"
#define KEY_IMAGEMSG_THUMBNAIL_IMAGE @"thumbnailImage"
#define KEY_IMAGEMSG_ORIGINAL_IMAGE @"originalImage"
#define KEY_IMAGEMSG_IMAGE_URL @"imageUrl"
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self) {
    self.extra = [aDecoder decodeObjectForKey:KEY_IMAGEMSG_EXTRA];
    self.thumbnailImage =
        [aDecoder decodeObjectForKey:KEY_IMAGEMSG_THUMBNAIL_IMAGE];
    self.imageUrl = [aDecoder decodeObjectForKey:KEY_IMAGEMSG_IMAGE_URL];
    self.originalImage =
        [aDecoder decodeObjectForKey:KEY_IMAGEMSG_ORIGINAL_IMAGE];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.extra forKey:KEY_IMAGEMSG_EXTRA];
  [aCoder encodeObject:self.thumbnailImage forKey:KEY_IMAGEMSG_THUMBNAIL_IMAGE];
  [aCoder encodeObject:self.imageUrl forKey:KEY_IMAGEMSG_IMAGE_URL];
  [aCoder encodeObject:self.originalImage forKey:KEY_IMAGEMSG_ORIGINAL_IMAGE];
}

#pragma mark - RCMessageCoding delegate methods
- (NSData *)encode {
  NSData *imageData = UIImageJPEGRepresentation(
      self.thumbnailImage,
      [RCLocalConfiguration sharedInstance].thumbnailQuality);
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

  NSMutableDictionary *dataDict = [NSMutableDictionary
      dictionaryWithObjectsAndKeys:thumbnailBase64String, @"content",
                                   self.imageUrl, @"imageUri", nil];
  if (self.extra) {
    [dataDict setObject:self.extra forKey:@"extra"];
  }
  if (self.isFull) {
    [dataDict setValue:@(self.isFull) forKey:@"full"];
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
    self.imageUrl = [jsonDictionary stringObjectForKey:@"imageUri"];
    self.extra = [jsonDictionary stringObjectForKey:@"extra"];
    self.full = [[jsonDictionary numberObjectForKey:@"full"] boolValue];

    NSDictionary *userinfoDic = [jsonDictionary objectForKey:@"user"];
    [super decodeUserInfo:userinfoDic];
    NSDictionary *mentionedInfoDic = [json objectForKey:@"mentionedInfo"];
    [self decodeMentionedInfo:mentionedInfoDic];
    self.thumbnailBase64String = [jsonDictionary stringObjectForKey:@"content"];
  } else {
    RCLogE(@"ERROR: RCImageMessage JSON is nil!!");
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
      self.thumbnailImage = [UIImage imageWithData:imageData];
    } else {
      RCLogI(@">>>>>>>> Error!!!!!!!! thumbnail is missing...");
    }
  }
  return _thumbnailImage;
}

- (NSString *)imageUrl {
  if ([RCUtilities isLocalPath:_imageUrl]) {
    _imageUrl = [RCUtilities getCorrectedFilePath:_imageUrl];
  }

  return _imageUrl;
}

+ (NSString *)getObjectName {
  return RCImageMessageTypeIdentifier;
}

#if !__has_feature(objc_arc)
- (void)dealloc {
  [super dealloc];
}
#endif //__has_feature(objc_arc)
@end
