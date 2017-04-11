//
//  CCNetwokKit.h
//  CustomerService
//
//  Created by birney on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <Foundation/Foundation.h>


//#define APPKEY @"n19jmcy59ocx9"
//#define APPSECRET @"PblLNSx3hSkW"


#define APPKEY @"lmxuhwaglck9d"
#define APPSECRET @"t6ZKDZnULwLuC"

@interface CCNetwokKit : NSObject

+ (instancetype)defaultKit;


- (void)fetchTokenWithUserId:(NSString*)usrId
                        name:(NSString*)usrName
                    success:(void (^)(NSString* token))sucess
                       error:(void (^)(NSError* error))errorBlock;
@end
