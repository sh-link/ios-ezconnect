//
//  SlaveListViewCellTableViewCell.h
//  SHLink
//
//  Created by zhen yang on 15/4/15.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellFrame.h"
@interface SlaveListViewCellTableViewCell : UITableViewCell

@property (nonatomic, assign) CGFloat height;

-(void)setContent:(NSString*)content;
-(void)setImg:(NSString*)imgName;
-(void)showRTX:(BOOL)isShow;
-(void)setRX:(int)rx;
-(void)setTx:(int)tx;

-(void)setCellFrame:(CellFrame*)cellFrame;
@end
