//
//  IPUtil.h
//  SHLink
//
//  Created by zhen yang on 15/7/11.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPUtil : NSObject
+(BOOL)isIPValid:(NSString*)ip;
+(BOOL)isPureInt:(NSString*)string;

+(BOOL)isMaskValid:(NSString*)mask;
+(NSString*)getBinary:(char)hex;


+(BOOL)isIPMaskGatewayValid:(NSString*)ip mask:(NSString*)mask gateway:(NSString*)gateway;
@end
