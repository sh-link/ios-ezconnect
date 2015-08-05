//
//  SHTabBarButton.m
//  SHLink
//
//  Created by zhen yang on 15/3/19.
//  Copyright (c) 2015年 Qiankai. All rights reserved.
//

#import "SHTabBarButton.h"
@interface SHTabBarButton()
@end
@implementation SHTabBarButton

-(void)setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType{
    //#99CC4F
    self.backgroundColor = [UIColor colorWithRed:0x4a/255.0 green:0x4a/255.0 blue:0x4a/255.0 alpha:1.0f];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(8.0,
                                        
                                              0.0,
                                              
                                              8.0,
                                              
                                              0.0)];
    [self setImage:image forState:stateType];
    [self.titleLabel setContentMode:UIViewContentModeScaleAspectFill];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self.titleLabel setTextColor:[UIColor redColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(8.0,
                                              
                                              8.0,
                                              
                                              8.0,
                                              
                                              0.0)];
    
    [self setTitle:title forState:stateType];}
@end
