//
//  UserDefaultUtil.h
//  SHLink
//
//  Created by zhen yang on 15/7/2.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultUtil : NSObject
+(void)setString:(NSString*)value forKey:(NSString*)key;
+(NSString*)getStringForKey:(NSString*)key defaultValue:(NSString*)defaultValue;

+(void)setInt:(int)value forKey:(NSString*)key;
+(int)getIntForKey:(NSString*)key;

+(void)removeKey:(NSString*)key;
@end
