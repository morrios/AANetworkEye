//
//  NSObject+AA.m
//  merchant
//
//  Created by beequick on 2018/1/31.
//  Copyright © 2018年 beequick. All rights reserved.
//

#import "NSObject+AA.h"
#import <objc/runtime.h>
  
@implementation NSObject (AA)

+ (NSMutableArray *)modelToArray{
    unsigned int count;
    Ivar *ivarList = class_copyIvarList(self, &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [name substringFromIndex:1];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        NSRange range = [type rangeOfString:@"\""];
        if (range.length) {
            type = [type substringFromIndex:range.location + range.length];
            range = [type rangeOfString:@"\""];
            type = [type substringToIndex:range.location];
        }
        
        if ([type isEqualToString: @"NSString"]||[type isEqualToString: @"d"]||[type isEqualToString: @"q"]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:key forKey:@"key"];
            [dict setObject:type forKey:@"type"];
            [array addObject:dict];
        }
  
    }
    return array;
}

+ (NSString *)modelToCreateSql:(NSString *)tableName{
    return [self modelToCreateSql:tableName primaryKey:@""];
}

- (NSString *)getClassName{
    return NSStringFromClass([self class]);
}

+ (NSString *)modelToCreateSql:(NSString *)tableName primaryKey:(NSString *)primaryKay {
    NSArray *array = [self modelToArray];
    NSString *str = [NSString stringWithFormat: @"create table if not exists %@(",tableName];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = array[i];
        NSString *tmp = dict[@"key"];
        if ([dict[@"type"] isEqualToString: @"NSString"]) {
            tmp = [tmp stringByAppendingString:@" text"];
        }else if ([dict[@"type"] isEqualToString: @"d"]) {
            tmp = [tmp stringByAppendingString:@" double"];
        }else if ([dict[@"type"] isEqualToString: @"q"]) {
            tmp = [tmp stringByAppendingString:@" int"];
        }else{
            tmp = @"";
        }
        
        if ([dict[@"key"] isEqualToString:primaryKay]) {
            tmp = [tmp stringByAppendingString:@" primary key"];
        }
        
        if (tmp.length>0) {
            if (i != array.count-1) {
                tmp = [tmp stringByAppendingString:@","];
            }else{
                tmp = [tmp stringByAppendingString:@")"];
            }
            str = [str stringByAppendingString:tmp];
        }
    }
    
    return str;
}

+ (NSString *)modelToInsertSqlStringByTableName:(NSString *)tableName{
    NSArray *array = [self modelToArray];
    NSString *str = [NSString stringWithFormat:@"INSERT INTO %@ (name, age, sex) VALUES (?,?,?)", tableName];
    NSString *nameStr = @"(";
    NSString *values = @"(";
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = array[i];
        NSString *nameTmp = dict[@"key"];
        NSString *que = @"?";
        if (i != array.count-1) {
            nameTmp = [nameTmp stringByAppendingString:@","];
            que = [que stringByAppendingString:@","];
        }else{
            nameTmp = [nameTmp stringByAppendingString:@")"];
            que = [que stringByAppendingString:@")"];
        }
        nameStr = [nameStr stringByAppendingString:nameTmp];
        values = [values stringByAppendingString:que];
    }
    str = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@", tableName, nameStr, values];
    return str;
}
- (NSMutableDictionary *)InsertSQLKeyAndValues{
    NSString *keys = @"";
    NSString *question = @"";
    NSMutableArray *values = [NSMutableArray array];
    unsigned int count;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        // 根据角标，从数组取出对应的成员属性
        Ivar ivar = ivarList[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [name substringFromIndex:1];
        NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        NSRange range = [type rangeOfString:@"\""];
        if (range.length) {
            type = [type substringFromIndex:range.location + range.length];
            range = [type rangeOfString:@"\""];
            if (range.length) {
                type = [type substringToIndex:range.location];
            }
        }
        if ([type isEqualToString: @"NSString"]||[type isEqualToString: @"d"]||[type isEqualToString: @"q"]) {
            id value = [self valueForKey:key];
            keys = [NSString stringWithFormat:@"%@,%@", keys, key];
            question = [NSString stringWithFormat:@"%@,?", question];
            [values addObject:value?value:@""];
        }
    }
    //////
    keys = [keys substringFromIndex:1];
    question = [question substringFromIndex:1];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:keys forKey:@"key"];
    [dict setObject:question forKey:@"question"];
    [dict setObject:values forKey:@"value"];
    return dict;
}


@end
