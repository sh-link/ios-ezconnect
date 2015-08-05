//
//  DeviceInfo.h
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
@property (nonatomic, strong) NSString *MAC;
@property (nonatomic, strong) NSString *NAME;
@property (nonatomic, assign) int P_CONT;
@property (nonatomic, assign) int checked;
@end
