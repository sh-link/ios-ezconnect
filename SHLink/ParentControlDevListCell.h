//
//  ParentControlDevListCell.h
//  SHLink
//
//  Created by zhen yang on 15/5/18.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckBox.h"
#import "ParentControlCellFrame.h"
@interface ParentControlDevListCell : UITableViewCell
@property (nonatomic, copy) ParentControlCellFrame *cellFrame;
@property (nonatomic, copy) CheckBox *checkBox;
+(instancetype)cellWithTableView:(UITableView*)tableView showCheckBox:(BOOL)isShow;
@end
