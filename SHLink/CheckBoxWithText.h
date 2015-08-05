//
//  CheckBoxWithText.h
//  SHLink
//
//  Created by zhen yang on 15/5/20.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBoxWithText : UIControl

-(void)setTitle:(NSString*)title;
+(CheckBoxWithText*)getCheckBox:(NSString*)title;
-(BOOL)getState;
@end
