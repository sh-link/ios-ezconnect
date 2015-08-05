//
//  DeviceInfo.m
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

-(NSString*)description
{
    return [NSString stringWithFormat:@"mac = %@, name = %@, checked = %d, p_cont = %d", self.MAC, self.NAME, self.checked, self.P_CONT];
}

-(BOOL)isEqual:(id)object
{
    DeviceInfo *device = object;
    
    return [self.MAC isEqualToString:device.MAC];
}
@end
