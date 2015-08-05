//
//  AddDeviceCellTableViewCell.h
//  SHLink
//
//  Created by zhen yang on 15/5/21.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddDeviceFrame.h"
#import "CheckBox.h"
@interface AddDeviceCellTableViewCell : UITableViewCell
@property (nonatomic, copy) AddDeviceFrame *cellFrame;
@property (nonatomic, copy) CheckBox *checkBox;
+(instancetype)cellWithTableView:(UITableView*)tableView;
@end
