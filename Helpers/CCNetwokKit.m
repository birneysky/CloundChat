//
//  CCNetwokKit.m
//  CustomerService
//
//  Created by birney on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import "CCNetwokKit.h"
#import <AFNetworking/AFNetworking.h>

#include <CommonCrypto/CommonHMAC.h>

static CCNetwokKit* defaultKit;

@implementation CCNetwokKit

+ (instancetype)defaultKit
{
    if (!defaultKit) {
        defaultKit = [[CCNetwokKit alloc] init];
        //[defaultKit networkEngine];
    }
    return defaultKit;
}



+ (instancetype) allocWithZone:(struct _NSZone *)zone
{
    if (!defaultKit) {
        defaultKit = [super allocWithZone:zone];
    }
    return defaultKit;
}

- (instancetype) copy{
    return defaultKit;
}


+ (AFHTTPSessionManager *)manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer.timeoutInterval = 20;
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}

- (void)fetchTokenWithUserId:(NSString*)usrId
                        name:(NSString*)usrName
                     success:(void (^)(NSString* token))sucess
                       error:(void (^)(NSError* error))errorBlock
{
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSDictionary<NSString*,NSString*>* parms = [CCNetwokKit parms];
    
    NSURL* urlPost = [NSURL URLWithString:@"http://api.cn.ronghub.com/user/getToken.json"];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"POST";
    [parms enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString* body = [NSString stringWithFormat:@"userId=%@&name=%@",usrId,usrName];
    NSData* data = [NSData dataWithBytes:body.UTF8String length:body.length];
    request.HTTPBody = data;
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error %@",error);
            errorBlock(error);
        }
        else{
            NSLog(@"success %@",responseObject);
            NSDictionary* response = responseObject;
            sucess(response[@"token"]);
        }
    }] resume];
    
}


#pragma mark - Helper

+ (NSDictionary<NSString*,NSString*> *) parms
{
    uint32_t random = arc4random();
    time_t timeStamp = time(NULL);
    uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {};
    NSString* sumString  = [NSString stringWithFormat:@"%@%u%ld",APPSECRET,random,timeStamp];
    CC_SHA1(sumString.UTF8String,(CC_LONG)sumString.length,digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i] & 0xFF];
    
    NSString* strTimeStamp = [NSString stringWithFormat:@"%ld",timeStamp];
    NSString* strRandom = [NSString stringWithFormat:@"%u",random];
    
    NSDictionary* parms = @{@"App-Key":APPKEY,@"Nonce":strRandom,@"Timestamp":strTimeStamp,@"Signature":[output copy]};
    return parms;
    ///test
}

@end
