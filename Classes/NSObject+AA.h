//
//  NSObject+AA.h
//  merchant
//
//  Created by beequick on 2018/1/31.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NSObject (AA)
+ (NSMutableArray *)modelToArray;
+ (NSString *)modelToCreateSql:(NSString *)tableName;
+ (NSString *)modelToCreateSql:(NSString *)tableName primaryKey:(NSString *)primaryKay ;

- (NSMutableDictionary *)InsertSQLKeyAndValues;
- (NSString *)getClassName;

@end
