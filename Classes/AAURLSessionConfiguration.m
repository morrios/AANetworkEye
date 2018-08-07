//
//  AAURLSessionConfiguration.m
//  merchant
//
//  Created by beequick on 2018/1/24.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import "AAURLSessionConfiguration.h"
#import <objc/runtime.h>
#import "AAWatchEyeURLProtocol.h"

@implementation AAURLSessionConfiguration
+ (AAURLSessionConfiguration *)defaultConfiguration {
    
    static AAURLSessionConfiguration *staticConfiguration;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticConfiguration=[[AAURLSessionConfiguration alloc] init];
    });
    return staticConfiguration;
    
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSwizzle=NO;
    }
    return self;
}

- (void)load{
    self.isSwizzle = YES;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}

- (void)unload{
    self.isSwizzle=NO;
    Class cls = NSClassFromString(@"__NSCFURLSessionConfiguration") ?: NSClassFromString(@"NSURLSessionConfiguration");
    [self swizzleSelector:@selector(protocolClasses) fromClass:cls toClass:[self class]];
}
- (void)swizzleSelector:(SEL)selector fromClass:(Class)original toClass:(Class)stub{
    Method originalMethod = class_getInstanceMethod(original, selector);
    Method stubMethod = class_getInstanceMethod(stub, selector);
    if (!originalMethod || !stubMethod) {
        [NSException raise:NSInternalInconsistencyException format:@"Couldn't load NEURLSessionConfiguration."];
    }
    method_exchangeImplementations(originalMethod, stubMethod);
    
}
- (NSArray *)protocolClasses {
    
    return @[[AAWatchEyeURLProtocol class]];//如果需要导入其他的自定义NSURLProtocol请在这里增加，当然在使用NSURLSessionConfiguration时增加也可以
}
@end
