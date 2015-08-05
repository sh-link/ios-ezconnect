//
//  ImageUtil.m
//  SHLink
//
//  Created by zhen yang on 15/4/25.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ImageUtil.h"
#import <UIKit/UIKit.h>
@implementation ImageUtil

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



@end
