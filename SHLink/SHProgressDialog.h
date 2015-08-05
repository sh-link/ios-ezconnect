//
//  SHProgressDialog.h
//  SHLink
//
//  Created by zhen yang on 15/3/31.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SHProgressDialog : NSObject
+(void)showDialog:(NSString*)msg ViewController:(UIViewController*)controller;
+(void)dismiss;
@end
