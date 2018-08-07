//
//  AAURLSessionConfiguration.h
//  merchant
//
//  Created by beequick on 2018/1/24.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAURLSessionConfiguration : NSObject

@property (nonatomic,assign) BOOL isSwizzle;// whether swizzle NSURLSessionConfiguration's protocolClasses method

/**
 *  get NEURLSessionConfiguration's singleton object
 *
 *  @return singleton object
 */
+ (AAURLSessionConfiguration *)defaultConfiguration;

/**
 *  swizzle NSURLSessionConfiguration's protocolClasses method
 */
- (void)load;

/**
 *  make NSURLSessionConfiguration's protocolClasses method is normal
 */
- (void)unload;
@end
