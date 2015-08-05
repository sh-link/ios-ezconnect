//
//  MessageUtil.h
//  SHLink
//
//  Created by zhen yang on 15/4/17.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageUtil : NSObject
+(void)showToast:(NSString*)toast time:(int)time;

+(void)showShortToast:(NSString*)toast;

+(void)showLongToast:(NSString*)toast;
@end
