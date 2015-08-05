//
//  ParentControlCellFrame.h
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DeviceInfo.h"
@interface ParentControlCellFrame : NSObject
@property (nonatomic, strong) DeviceInfo *deviceInfo;
@property (nonatomic, assign) CGRect containerViewF;
@property (nonatomic, assign) CGRect imgViewF;
@property (nonatomic, assign) CGRect macViewF;
@property (nonatomic, assign) CGRect nameViewF;
@property (nonatomic, assign) CGRect checkBoxViewF;
@property (nonatomic, assign) CGFloat cellHeight;
@end
