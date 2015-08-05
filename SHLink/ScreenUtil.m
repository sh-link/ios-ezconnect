//
//  ScreenUtil.m
//  SHLink
//
//  Created by zhen yang on 15/4/16.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ScreenUtil.h"
@implementation ScreenUtil

+(CGFloat)getHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

+(CGFloat)getWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}
@end
