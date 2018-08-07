//
//  AAWatchEyeURLProtocol.m
//  merchant
//
//  Created by beequick on 2018/1/23.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import "AAWatchEyeURLProtocol.h"
#import "AAURLSessionConfiguration.h"
#import "NEHTTPModel.h"
#import "AAHTTPModelCache.h"

static NSString * const hasInitKey = @"AAWatchEyeURLProtocolKey";

@interface AAWatchEyeURLProtocol ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic,strong) NEHTTPModel *ne_HTTPModel;

@end

@implementation AAWatchEyeURLProtocol
@synthesize ne_HTTPModel;
+ (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setDouble:enabled forKey:@"NetworkEyeEnable"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    AAURLSessionConfiguration * sessionConfiguration=[AAURLSessionConfiguration defaultConfiguration];
    
    if (enabled) {
        [NSURLProtocol registerClass:[AAWatchEyeURLProtocol class]];
        if (![sessionConfiguration isSwizzle]) {
            [sessionConfiguration load];
        }
        
        //注册scheme
        Class cls = NSClassFromString(@"WKBrowsingContextController");
        SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
        if ([cls respondsToSelector:sel]) {
            // 通过http和https的请求，同理可通过其他的Scheme 但是要满足ULR Loading System
            [cls performSelector:sel withObject:@"http"];
            [cls performSelector:sel withObject:@"https"];
        }
        
    }else{
        [NSURLProtocol unregisterClass:[AAWatchEyeURLProtocol class]];
        if ([sessionConfiguration isSwizzle]) {
            [sessionConfiguration unload];
        }
    }

}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey:hasInitKey inRequest:request]) {
        return NO;
    }
    
    
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //这边可用干你想干的事情。。更改地址，或者设置里面的请求头。。
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:mutableReqeust];

    return [mutableReqeust copy];
}

- (void)startLoading
{
  
    self.startDate = [NSDate date];
    self.data = [NSMutableData data];
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:mutableReqeust];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    
    ne_HTTPModel=[[NEHTTPModel alloc] init];
    ne_HTTPModel.ne_request=self.request;
    
    ne_HTTPModel.startDateString=[self stringWithDate:[NSDate date]];
    ne_HTTPModel.startTimestamp = [NSString stringWithFormat:@"%ld",time(NULL)];
    NSTimeInterval myID=[[NSDate date] timeIntervalSince1970];
    double randomNum=((double)(arc4random() % 100))/10000;
    ne_HTTPModel.myID=myID+randomNum;

}

- (void)stopLoading
{
    ne_HTTPModel.ne_response=(NSHTTPURLResponse *)self.response;
    ne_HTTPModel.endDateString=[self stringWithDate:[NSDate date]];
    [self.connection cancel];
    NSString *xmlString = [self dataToReadStr:self.data];
    
    if (xmlString && xmlString.length>0) {
        ne_HTTPModel.receiveJSONData = xmlString;//example http://webservice.webxml.com.cn/webservices/qqOnlineWebService.asmx/qqCheckOnline?qqCode=2121

    }
    double flowCount=[[[NSUserDefaults standardUserDefaults] objectForKey:@"flowCount"] doubleValue];
    if (!flowCount) {
        flowCount=0.0;
    }
    flowCount=flowCount+self.response.expectedContentLength/(1024.0*1024.0);
    [[NSUserDefaults standardUserDefaults] setDouble:flowCount forKey:@"flowCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];//https://github.com/coderyi/NetworkEye/pull/6
    [[AAHTTPModelCache share] addModel:ne_HTTPModel];
}

- (NSString *)dataToReadStr:(NSData*)data{
    if (data == nil) {
        
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (dict) {
        NSData *newdata=[NSJSONSerialization dataWithJSONObject:dict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:nil];
        
        
        
        NSString *str=[[NSString alloc] initWithData:newdata encoding:NSUTF8StringEncoding];
        return str;
    }
    return nil;
   
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [[self client] URLProtocol:self didFailWithError:error];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil){
        self.response = response;
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *mimeType = self.response.MIMEType;
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}
- (NSString *)stringWithDate:(NSDate *)date {
    NSString *destDateString = [[AAWatchEyeURLProtocol defaultDateFormatter] stringFromDate:date];
    return destDateString;
}

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *staticDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticDateFormatter=[[NSDateFormatter alloc] init];
        [staticDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];//zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    });
    return staticDateFormatter;
}
@end
