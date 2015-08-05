//
//  CustomAlertView.h
//  SHLink
//
//  Created by zhen yang on 15/3/24.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomAlerViewDelegate<NSObject>

-(void)onCancelClick;
-(void)onOkClick;

@end
@interface CustomAlertView : UIView

-(void)setTitleIcon:(UIImage*)icon;
-(void)setTitle:(NSString*)title;
-(void)setMessage:(NSString*)message;
-(void)show;
@property id<CustomAlerViewDelegate> delegate;
@end
