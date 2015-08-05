//
//  UserDefaultUtil.m
//  SHLink
//
//  Created by zhen yang on 15/7/2.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "UserDefaultUtil.h"

@implementation UserDefaultUtil

+(void)setString:(NSString *)value forKey:(NSString *)key
{
    //去除空格
    NSMutableString *str = [NSMutableString stringWithString:value];
    [str replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, value.length)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:str forKey:key];
    [userDefaults synchronize];
}

+(NSString*)getStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* result = [userDefaults objectForKey:key];
    if(result == nil)
    {
        return defaultValue;
    }
    return result;
}


+(void)setInt:(int)value forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:key];
    [userDefaults synchronize];
}

+(int)getIntForKey:(NSString*)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int result = [userDefaults integerForKey:key];
    return result;
}

+(void)removeKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}


@end
