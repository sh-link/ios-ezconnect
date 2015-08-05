//
//  SHDevice.h
//  SHLink
//
//  Created by 钱凯 on 15/1/22.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHDevice : NSObject
//设备基本信息
@property (nonatomic, retain) NSString *lanIp;
@property (nonatomic, retain) NSString *wanIp;
@property (nonatomic, retain) NSString *mac;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;

@end
