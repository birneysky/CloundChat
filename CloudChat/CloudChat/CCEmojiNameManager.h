//
//  CCEmojiNameManager.h
//  CloudChat
//
//  Created by birneysky on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCEmojiNameManager : NSObject

- (NSString*)nameAtIndex:(NSInteger)index;

- (NSString*)indexOfName:(NSString*)name;

+ (instancetype)defaultManager;

@end
