//
//  AAHTTPModelCache.h
//  merchant
//
//  Created by beequick on 2018/1/31.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NEHTTPModel.h"

@interface AAHTTPModelCache : NSObject
+ (instancetype)share;
- (void)addModel:(NEHTTPModel *)model;
- (NSMutableArray *)allobjects;
- (void)cleanAllRecode;

@end
