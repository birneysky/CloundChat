//
//  CCNetwokKit.h
//  CustomerService
//
//  Created by birney on 2017/4/5.
//  Copyright © 2017年 birney. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCNetwokKit : NSObject

+ (instancetype)defaultKit;


- (void)fetchTokenWithUserId:(NSString*)usrId
                        name:(NSString*)usrName
                    success:(void (^)(NSString* token))sucess
                       error:(void (^)(NSError* error))errorBlock;
@end
