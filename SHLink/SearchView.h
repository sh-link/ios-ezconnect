//
//  SearchView.h
//  SHLink
//
//  Created by zhen yang on 15/4/16.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchView : UIView
+(SearchView *)initWithMsg:(NSString*)msg;
-(void)setMsg:(NSString*)msg;
-(void)setColor:(UIColor*)color;
@end
