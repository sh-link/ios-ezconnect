//
//  Utils.h
//  SHLink
//
//  Created by zhen yang on 15/3/28.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Utils : NSObject
+(void)showToast:(NSString*)toast viewController:(UIViewController*)controller;
+(void)showAlertView:(NSString*)message;
+(BOOL)checkIP:(NSString*)ip;
@end
