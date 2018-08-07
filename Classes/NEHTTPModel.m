//
//  NEHTTPModel.m
//  NetworkEye
//
//  Created by coderyi on 15/11/4.
//  Copyright © 2015年 coderyi. All rights reserved.
//

#import "NEHTTPModel.h"

@implementation NEHTTPModel
@synthesize ne_request,ne_response;

-(void)setNe_request:(NSURLRequest *)ne_request_new{
    ne_request=ne_request_new;
    self.requestURLString=[ne_request.URL absoluteString];
    
    switch (ne_request.cachePolicy) {
        case 0:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 1:
            self.requestCachePolicy=@"NSURLRequestReloadIgnoringLocalCacheData";
            break;
        case 2:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataElseLoad";
            break;
        case 3:
            self.requestCachePolicy=@"NSURLRequestReturnCacheDataDontLoad";
            break;
        case 4:
            self.requestCachePolicy=@"NSURLRequestUseProtocolCachePolicy";
            break;
        case 5:
            self.requestCachePolicy=@"NSURLRequestReloadRevalidatingCacheData";
            break;
        default:
            self.requestCachePolicy=@"";
            break;
    }
    
    self.requestTimeoutInterval=[[NSString stringWithFormat:@"%.1lf",ne_request.timeoutInterval] doubleValue];
    self.requestHTTPMethod=ne_request.HTTPMethod;
    
    for (NSString *key in [ne_request.allHTTPHeaderFields allKeys]) {
        self.requestAllHTTPHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.requestAllHTTPHeaderFields,key,[ne_request.allHTTPHeaderFields objectForKey:key]];
    }
    if (self.requestAllHTTPHeaderFields.length>1) {
        if ([[self.requestAllHTTPHeaderFields substringFromIndex:self.requestAllHTTPHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringToIndex:self.requestAllHTTPHeaderFields.length-1];
        }
    }
    if (self.requestAllHTTPHeaderFields.length>6) {
        if ([[self.requestAllHTTPHeaderFields substringToIndex:6] isEqualToString:@"(null)"]) {
            self.requestAllHTTPHeaderFields=[self.requestAllHTTPHeaderFields substringFromIndex:6];
        }
    }

    if ([ne_request HTTPBody].length>512) {
        self.requestHTTPBody=@"requestHTTPBody too long";
    }else{
        if ([self.requestHTTPMethod isEqualToString:@"POST"]) {
            if (![ne_request HTTPBody]) {
                uint8_t d[1024] = {0};
                NSInputStream *stream = self.ne_request.HTTPBodyStream;
                NSMutableData *data = [[NSMutableData alloc] init];
                [stream open];
                while ([stream hasBytesAvailable]) {
                    NSInteger len = [stream read:d maxLength:1024];
                    if (len > 0 && stream.streamError == nil) {
                        [data appendBytes:(void *)d length:len];
                    }
                }
                NSString *temp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                self.requestHTTPBody = [temp stringByRemovingPercentEncoding];
                
                [stream close];
            }
            
        }else{
            self.requestHTTPBody=[[NSString alloc] initWithData:[ne_request HTTPBody] encoding:NSUTF8StringEncoding];
            
        }
    }
    

    
    if (self.requestHTTPBody.length>1) {
        if ([[self.requestHTTPBody substringFromIndex:self.requestHTTPBody.length-1] isEqualToString:@"\n"]) {
            self.requestHTTPBody=[self.requestHTTPBody substringToIndex:self.requestHTTPBody.length-1];
        }
    }
    
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
    }else{
        NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [str componentsSeparatedByString:@"&"];
        NSString *newStr = @"{";
        for (int i=0 ; i<array.count; i++) {
            NSString *sub = [self strFormat:array[i]];
            if (i!=(array.count-1)) {
                sub = [NSString stringWithFormat:@"%@,",sub];
            }
            newStr = [NSString stringWithFormat:@"%@%@",newStr,sub];
        }
        newStr = [NSString stringWithFormat:@"%@}",newStr];

        
        NSData *jsonData = [newStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        NSData *newdata=[NSJSONSerialization dataWithJSONObject:dict
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:nil];
        
        NSString *reslut=[[NSString alloc] initWithData:newdata encoding:NSUTF8StringEncoding];
        
        return reslut;
    }
    return nil;
}
- (NSString *)JSONStr{
    NSData *data =[_JsonRead dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
- (NSString *)strFormat:(NSString *)str{
    NSArray *array = [str componentsSeparatedByString:@"="];
    NSString *jsonStr = @"";
    if (array.count==2) {
        jsonStr = [NSString stringWithFormat:@"\"%@\":\"%@\"",array[0],array[1]];
    }
    return jsonStr;
}

- (void)setNe_response:(NSHTTPURLResponse *)ne_response_new {
    
    ne_response=ne_response_new;
    
    self.responseMIMEType=@"";
    self.responseExpectedContentLength=@"";
    self.responseTextEncodingName=@"";
    self.responseSuggestedFilename=@"";
    self.responseStatusCode=200;
    self.responseAllHeaderFields=@"";
    
    self.responseMIMEType=[ne_response MIMEType];
    self.responseExpectedContentLength=[NSString stringWithFormat:@"%lld",[ne_response expectedContentLength]];
    self.responseTextEncodingName=[ne_response textEncodingName];
    self.responseSuggestedFilename=[ne_response suggestedFilename];
    self.responseStatusCode=(int)ne_response.statusCode;
    
    for (NSString *key in [ne_response.allHeaderFields allKeys]) {
        NSString *headerFieldValue=[ne_response.allHeaderFields objectForKey:key];
        if ([key isEqualToString:@"Content-Security-Policy"]) {
            if ([[headerFieldValue substringFromIndex:12] isEqualToString:@"'none'"]) {
                headerFieldValue=[headerFieldValue substringToIndex:11];
            }
        }
        self.responseAllHeaderFields=[NSString stringWithFormat:@"%@%@:%@\n",self.responseAllHeaderFields,key,headerFieldValue];
        
    }
    
    if (self.responseAllHeaderFields.length>1) {
        if ([[self.responseAllHeaderFields substringFromIndex:self.responseAllHeaderFields.length-1] isEqualToString:@"\n"]) {
            self.responseAllHeaderFields=[self.responseAllHeaderFields substringToIndex:self.responseAllHeaderFields.length-1];
        }
    }
}
- (NSString *)startTimestamp{
    if(!_startTimestamp){
        _startTimestamp = @"000";
    }
    return _startTimestamp;
}


@end
