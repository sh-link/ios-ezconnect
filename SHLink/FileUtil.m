//
//  FileUtil.m
//  SHLink
//
//  Created by zhen yang on 15/7/2.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "FileUtil.h"

@implementation FileUtil
//获取应用沙盒temp目录
+(NSString*)getDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
//获取应用沙盒document目录
+(NSString*)getTempPath
{
   
    return NSTemporaryDirectory();
}
@end
