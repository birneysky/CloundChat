//
//  CCEmojiNameManager.m
//  CloudChat
//
//  Created by birneysky on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCEmojiNameManager.h"


static CCEmojiNameManager* manager = nil;

@interface CCEmojiNameManager ()

@property (nonatomic,copy) NSArray* names;

@property (nonatomic,strong) NSMutableDictionary<NSString*,NSString*>* nameIndexDic;

@end

@implementation CCEmojiNameManager
#pragma mark - *** Properties ***
- (NSMutableDictionary<NSString*,NSString*>*) nameIndexDic
{
    if (!_nameIndexDic) {
        _nameIndexDic = [[NSMutableDictionary alloc] init];
    }
    return _nameIndexDic;
}

#pragma mark - *** Initializers ***
+ (instancetype)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCEmojiNameManager alloc] init];
    });
    return manager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    if (!manager) {
        return  manager = [super allocWithZone:zone];
    }
    return nil;
}


- (instancetype)init{
    if (self = [super init]) {
        NSString * facePlistPath = [[NSBundle mainBundle] pathForResource:@"CCEmojiNames" ofType:@"plist"];
        NSArray* temp = [NSArray arrayWithContentsOfFile:facePlistPath];
        NSMutableArray* tempMutable = [[NSMutableArray alloc] initWithCapacity:50];
        for (int i = 0; i < temp.count; i++) {
            NSString* faceString =  temp[i];
            [tempMutable addObject:faceString];
            NSString* key = [NSString stringWithFormat:@"[%@]",faceString];
            NSString* value = [NSString stringWithFormat:@"%d",i];
            [self.nameIndexDic setObject:value forKey:key];
        }
        self.names = [tempMutable copy];
    }
    return self;
}

- (NSString*)nameAtIndex:(NSInteger)index
{
    assert(index < self.names.count);
    return self.names[index];
}


- (NSString*)indexOfName:(NSString*)name
{
    return self.nameIndexDic[name];
}


@end
