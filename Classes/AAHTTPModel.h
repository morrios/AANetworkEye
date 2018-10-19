//
//  AAHTTPModel.h
//  merchant
//
//  Created by beequick on 2018/10/18.
//  Copyright © 2018 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAHTTPModel : NSObject
@property (nonatomic,strong) NSURLRequest *aa_request;
@property (nonatomic,strong) NSHTTPURLResponse *aa_response;
@property (nonatomic,assign) double myID;
@property (nonatomic,strong) NSString *startDateString;
@property (nonatomic,strong) NSString *startTimestamp;
@property (nonatomic,strong) NSString *endDateString;
  
//request
@property (nonatomic,strong) NSString *requestURLString;
@property (nonatomic,strong) NSString *requestCachePolicy;
@property (nonatomic,assign) double requestTimeoutInterval;
@property (nonatomic,nullable, strong) NSString *requestHTTPMethod;
@property (nonatomic,nullable,strong) NSString *requestAllHTTPHeaderFields;
@property (nonatomic,nullable,strong) NSString *requestHTTPBody;

//response
@property (nonatomic,nullable,strong) NSString *responseMIMEType;
@property (nonatomic,strong) NSString * responseExpectedContentLength;
@property (nonatomic,nullable,strong) NSString *responseTextEncodingName;
@property (nullable, nonatomic, strong) NSString *responseSuggestedFilename;
@property (nonatomic,assign) NSInteger responseStatusCode;
@property (nonatomic,nullable,strong) NSString *responseAllHeaderFields;

//JSONData
@property (nonatomic,strong) NSString *receiveJSONData;
@property (nonatomic,strong) NSString *JsonRead;
@property (nonatomic,strong) NSString *mapPath;
@property (nonatomic,strong) NSString *JSONStr;
@end

NS_ASSUME_NONNULL_END
