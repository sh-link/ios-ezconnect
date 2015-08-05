//
//  ErrorUtil.m
//  SHLink
//
//  Created by zhen yang on 15/5/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "ErrorUtil.h"


@implementation ErrorUtil
+(NSString*)doForError:(NSError *)error
{
    
    NSInteger code = error.code;
    switch (code) {
        case -1:
            return @"出错了，网络故障";
        case -2:
            return @"出错了，网络故障";
        case -3:
            return @"出错了，请求超时";
        case 3:
            return @"出错了，该用户不存在";
        case 4:
            return @"出错了，密码错误";
        case 5:
            return @"出错了，查询或设置失败";
        case 6:
            return @"出错了，程序运行错误";
        case 7:
            return @"出错了，wan口未连接";
        case 8:
            return @"出错了，无线开关排期设置失败";
        case 9:
            return @"出错了，json格式不符合要求";
        case 10:
            return @"出错了，固件更新失败";
        case 11:
            return @"出错了，获取slave列表失败";
        case 12:
            return @"出错了，参数错误";
        case 13:
            return @"出错了，获取固件版本信息失败";
        case 14:
            return @"出错了，获取客户端列表失败";
        case 15:
            return @"出错了，设置名称失败";
        case 16:
            return @"未知错误";
        case 17:
            return @"出错了，家长控制时间设置失败";
        case 18:
            return @"出错了，mac地址格式错误";
        case 19:
            return @"出错了，家长控制列表已满，添加失败";
        case 20:
            return @"出错了，该设备不在家长控制列表中";
        case 21:
            return @"出错了，该设备已经存在家长控制列表中";
    }
    return @"未知错误";
}
@end
