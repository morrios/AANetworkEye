//
//  AAHTTPModelCache.m
//  merchant
//
//  Created by beequick on 2018/1/31.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import "AAHTTPModelCache.h"
//#import "FMDatabase.h"
//#import "FMDatabaseQueue.h"
#import "NSObject+AA.h"

static NSString *const AAHttpRequestCache = @"AA_httpRequestCache.sqlite";
@interface AAHTTPModelCache ()
@property(nonatomic,copy) NSString *dbPath;

@end
@implementation AAHTTPModelCache{
    FMDatabase *db;
    NSString *SQLTableName;
}

+ (instancetype)share{
    static AAHTTPModelCache *ADcache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!ADcache) {
            ADcache = [[AAHTTPModelCache alloc] init];
        }
    });
    return ADcache;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        SQLTableName = @"AAnetworkhttpeyes";
        [self createTable];
    }
    return self;
}
// 建表
- (void)createTable {
    db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        
        NSString *sql = [NEHTTPModel modelToCreateSql:SQLTableName primaryKey:@"myID"];
        
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [db close];
    } else {
        NSLog(@"error when open db");
    }
}
- (void)addModel:(NEHTTPModel *)model{
    if ([db open]) {
        NSMutableDictionary *dict = [model InsertSQLKeyAndValues];
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",SQLTableName,dict[@"key"], dict[@"question"]];
        [db executeUpdate:sql withArgumentsInArray:[dict[@"value"] copy]];
        [db close];
    }
}
- (void)cleanAllRecode{
    if ([db open]) {
        NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@", SQLTableName];
        [db executeUpdate:sqlStr];
        [db close];
    }
}
- (NSMutableArray *)allobjects{
    NSMutableArray *array=[NSMutableArray array];

    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select *from %@",SQLTableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            NEHTTPModel *model=[[NEHTTPModel alloc] init];
            model.myID=[rs doubleForColumn:@"myID"];
            model.startDateString=[rs stringForColumn:@"startDateString"];
            model.startTimestamp=[rs stringForColumn:@"startTimestamp"];
            model.endDateString=[rs stringForColumn:@"endDateString"];
            model.requestURLString=[rs stringForColumn:@"requestURLString"];
            model.requestCachePolicy=[rs stringForColumn:@"requestCachePolicy"];
            model.requestTimeoutInterval=[rs doubleForColumn:@"requestTimeoutInterval"];
            model.requestHTTPMethod=[rs stringForColumn:@"requestHTTPMethod"];
            model.requestAllHTTPHeaderFields=[rs stringForColumn:@"requestAllHTTPHeaderFields"];
            model.requestHTTPBody=[rs stringForColumn:@"requestHTTPBody"];
            model.responseMIMEType=[rs stringForColumn:@"responseMIMEType"];
            model.responseExpectedContentLength=[rs stringForColumn:@"responseExpectedContentLength"];
            model.responseTextEncodingName = [rs stringForColumn:@"responseTextEncodingName"];
            model.responseSuggestedFilename=[rs stringForColumn:@"responseSuggestedFilename"];
            model.responseStatusCode=[rs intForColumn:@"responseStatusCode"];
            model.responseAllHeaderFields=[rs stringForColumn:@"responseAllHeaderFields"];
            model.receiveJSONData=[rs stringForColumn:@"receiveJSONData"];
            [array addObject:model];
        }
        [db close];
    }
    
    NSArray *temp = [array sortedArrayUsingComparator:^NSComparisonResult(NEHTTPModel *  _Nonnull obj1, NEHTTPModel *  _Nonnull obj2) {
        NSInteger ob1 = [obj1.startTimestamp integerValue];
        NSInteger ob2 = [obj2.startTimestamp integerValue];
        if (ob2 > ob1) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    if (array.count>0) {
        [array removeAllObjects];
    }
    [array addObjectsFromArray:temp];
    return array;
}

- (NSString *)CachePath:(NSString *)name{
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    return path;
}

- (NSString *)dbPath{
    if (!_dbPath) {
        _dbPath = [self CachePath:AAHttpRequestCache];
    }
    return _dbPath;
}

@end
