//
//  CellFrame.h
//  SHLink
//
//  Created by zhen yang on 15/7/9.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SlaveInfo.h"
#define smallSize 15
@interface CellFrame : NSObject
@property (nonatomic, strong) SlaveInfo *info;
@property (nonatomic, assign) CGRect imgFrame;
@property (nonatomic, assign) CGRect macFrame;
@property (nonatomic, assign) CGRect rxFrame;
@property (nonatomic, assign) CGRect txFrame;
@property (nonatomic, assign) CGRect containerFrame;
@property (nonatomic, assign) CGFloat cellHeight;
@end
