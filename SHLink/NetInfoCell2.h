//
//  NetInfoCell2.h
//  SHLink
//
//  Created by zhen yang on 15/7/7.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetInfoCell.h"
@interface NetInfoCell2 : UIView
-(void)setTitle:(NSString*)title;
-(void)setContent:(NSString*)content;
-(int)getPadding;
-(void)setTitleColor:(UIColor *)color;
@end
