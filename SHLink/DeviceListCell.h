//
//  DeviceListCell.h
//  SHLink
//
//  Created by zhen yang on 15/4/23.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@interface DeviceListCell : SWTableViewCell
-(void)setMac:(NSString*)mac;
-(void)setSend:(int)send;
-(void)setRecv:(int)recv;
-(void)setName:(NSString*)name;
-(void)setImgWithImgName:(NSString*)imgName;
@property (nonatomic, assign)int totalHeight;
@end
