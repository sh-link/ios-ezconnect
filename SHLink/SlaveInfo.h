//
//  SlaveInfo.h
//  SHLink
//
//  Created by zhen yang on 15/7/8.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlaveInfo : NSObject
@property (nonatomic, copy) NSString *mac;
@property (nonatomic, assign)BOOL online;
@property (nonatomic, assign)int rx;
@property (nonatomic, assign)int tx;
@end
