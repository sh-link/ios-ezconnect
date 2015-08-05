//
//  SHMenuCell.h
//  SHLink
//
//  Created by 钱凯 on 15/1/28.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHMenuCell : UIControl
@property (nonatomic) NSString *title;
@property (nonatomic) UIImage *image;
-(void)setNumber:(int)number;
-(void)hideNumber;
@end
